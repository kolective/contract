// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Core.sol";
import "../src/TokenFactory.sol";
import "../src/MockToken.sol";

contract CoreTest is Test {
    Core core;
    TokenFactory factory;
    MockToken tokenA;
    MockToken tokenB;

    function setUp() public {
        core = new Core();
        factory = new TokenFactory();

        tokenA = MockToken(factory.createToken("Token A", "TKA", 10_000, 18, 1e18));
        tokenB = MockToken(factory.createToken("Token B", "TKB", 10_000, 18, 2e18));

        tokenA.approve(address(core), type(uint256).max);
        tokenB.approve(address(core), type(uint256).max);
    }

    function testAddLiquidity() public {
        core.addLiquidity(address(tokenA), 1_000 ether);
        assertEq(core.getLiquidity(address(tokenA)), 1_000 ether);
    }

    function testRemoveLiquidity() public {
        core.addLiquidity(address(tokenA), 1_000 ether);
        core.removeLiquidity(address(tokenA), 500 ether);
        assertEq(core.getLiquidity(address(tokenA)), 500 ether);
    }

    function testSetPriceAndLiquidity() public {
        core.setPriceAndLiquidity(address(tokenA), 2e18, 2_000 ether);
        assertEq(core.getLiquidity(address(tokenA)), 2_000 ether);
    }

    function testSwap() public {
        // Add initial liquidity
        core.addLiquidity(address(tokenA), 1_000 ether);
        core.addLiquidity(address(tokenB), 2_000 ether);

        // Transfer TKA to another account and approve
        address user = address(0xBEEF);
        tokenA.mint(user, 100 ether);
        vm.prank(user);
        tokenA.approve(address(core), 100 ether);

        // Simulate user swapping
        vm.prank(user);
        uint256 amountOut = core.swap(address(tokenA), address(tokenB), 100 ether);

        // Validate result
        assertGt(amountOut, 0);
        assertEq(core.getLiquidity(address(tokenA)), 1_100 ether);
        assertEq(core.getLiquidity(address(tokenB)), 2_000 ether - amountOut);
        assertEq(tokenB.balanceOf(user), amountOut);
    }
}
