// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Core {
    event Swap(
        address indexed sender,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 buyPrice,
        uint256 sellPrice
    );
    event LiquidityAdded(
        address indexed provider,
        address token,
        uint256 amount
    );
    event LiquidityRemoved(
        address indexed provider,
        address token,
        uint256 amount
    );
    event PriceUpdated(
        address indexed token,
        uint256 newPrice,
        uint256 newLiquidity
    );

    mapping(address => uint256) public liquidity;
    mapping(address => uint256) public tokenPrices;

    function addLiquidity(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        liquidity[token] += amount;
        emit LiquidityAdded(msg.sender, token, amount);
    }

    function removeLiquidity(address token, uint256 amount) external {
        require(liquidity[token] >= amount, "Insufficient liquidity");
        liquidity[token] -= amount;
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
        emit LiquidityRemoved(msg.sender, token, amount);
    }

    function getLiquidity(address token) external view returns (uint256) {
        return liquidity[token];
    }

    function setPriceAndLiquidity(address token, uint256 newPrice, uint256 newLiquidity) external {
        require(newLiquidity > 0, "Liquidity must be greater than zero");
        tokenPrices[token] = newPrice;
        liquidity[token] = newLiquidity;
        emit PriceUpdated(token, newPrice, newLiquidity);
    }

    function setPriceAndAutoSetLiquidity(address token, uint256 newPrice) external {
        require(newPrice > 0, "Price must be greater than zero");
        tokenPrices[token] = newPrice;
        uint256 newLiquidity = 1e18 / newPrice;
        liquidity[token] = newLiquidity;
        emit PriceUpdated(token, newPrice, newLiquidity);
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(
            tokenIn != address(0) && tokenOut != address(0),
            "Invalid token address"
        );
        require(amountIn > 0, "Amount must be greater than zero");
        require(
            liquidity[tokenIn] > 0 && liquidity[tokenOut] > 0,
            "Insufficient liquidity"
        );

        uint256 reserveIn = liquidity[tokenIn];
        uint256 reserveOut = liquidity[tokenOut];
        require(reserveIn > 0 && reserveOut > 0, "Invalid reserves");

        // Calculate buy price and sell price before the swap
        uint256 buyPrice = (reserveOut * 1e18) / reserveIn;
        uint256 sellPrice = (reserveIn * 1e18) / reserveOut;

        // Swap formula: x * y = k
        uint256 amountInWithFee = (amountIn * 997) / 1000; // 0.3% fee
        amountOut = (amountInWithFee * reserveOut) / (reserveIn + amountInWithFee);
        require(amountOut > 0, "Swap amount must be greater than zero");

        // Update liquidity
        liquidity[tokenIn] += amountIn;
        liquidity[tokenOut] -= amountOut;

        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "Token transfer failed"
        );
        require(
            IERC20(tokenOut).transfer(msg.sender, amountOut),
            "Token transfer failed"
        );

        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut, buyPrice, sellPrice);
    }
}
