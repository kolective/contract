// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockToken} from "../src/MockToken.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {Core} from "../src/Core.sol";
import {console} from "../lib/forge-std/src/console.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Deploy is Script {
    struct TokenInfo {
        string name;
        string symbol;
        uint8 decimals;
        uint256 initialSupply;
        uint256 liquidity;
        uint256 initialPrice;
    }

    function run() external {
        vm.startBroadcast();

        // Deploy TokenFactory
        TokenFactory factory = new TokenFactory();
        console.log("TokenFactory deployed at:", address(factory));

        // Deploy Core contract
        Core core = new Core();
        console.log("Core contract deployed at:", address(core));

        // Market price (scaled to avoid overflow)
        uint256 pharosPrice = 1 * 10**18; // $1
        uint256 ethPrice = 2719 * 10**18; // Approx $2,719
        uint256 btcPrice = 65300 * 10**18; // Approx $65,300
        uint256 wethPrice = 2719 * 10**18; // Approx $2,719
        uint256 pepePrice = 1100 * 10**14; // Approx $0.0011 (in wei)
        uint256 trumpPrice = 1592 * 10**18; // Approx $15.92
        uint256 dogeaiPrice = 62 * 10**15; // Approx $0.062
        uint256 wifPrice = 77 * 10**16; // Approx $0.77
        uint256 stonksPrice = 5 * 10**16; // Approx $0.05

        // Liquidity in USD
        uint256 liquidityUSD = 1_000_000 * 10**18; // $1,000,000 in wei

        // Calculate liquidity for each token
        uint256 ethLiquidity = Math.mulDiv(liquidityUSD, 10**18, ethPrice);
        uint256 btcLiquidity = Math.mulDiv(liquidityUSD, 10**18, btcPrice);
        uint256 wethLiquidity = Math.mulDiv(liquidityUSD, 10**18, wethPrice);
        uint256 pepeLiquidity = Math.mulDiv(liquidityUSD, 10**18, pepePrice);
        uint256 trumpLiquidity = Math.mulDiv(liquidityUSD, 10**18, trumpPrice);
        uint256 dogeaiLiquidity = Math.mulDiv(liquidityUSD, 10**18, dogeaiPrice);
        uint256 wifLiquidity = Math.mulDiv(liquidityUSD, 10**18, wifPrice);
        uint256 stonksLiquidity = Math.mulDiv(liquidityUSD, 10**18, stonksPrice);

        TokenInfo[9] memory tokens = [
            TokenInfo("Mock Pharos Network", "MPTT", 18, 1_000_000 * 10**18, liquidityUSD, pharosPrice),
            TokenInfo("Mock Ethereum", "METH", 18, 1_000_000 * 10**18, ethLiquidity, ethPrice),
            TokenInfo("Mock Bitcoin", "MBTC", 18, 1_000_000 * 10**18, btcLiquidity, btcPrice),
            TokenInfo("Mock Wrapped Ether", "MWETH", 18, 1_000_000 * 10**18, wethLiquidity, wethPrice),
            TokenInfo("Mock PEPE", "MPEPE", 18, 1_000_000 * 10**18, pepeLiquidity, pepePrice),
            TokenInfo("Mock OFFICIAL TRUMP", "MTRUMP", 18, 1_000_000 * 10**18, trumpLiquidity, trumpPrice),
            TokenInfo("Mock DOGE AI", "MDOGEAI", 18, 1_000_000 * 10**18, dogeaiLiquidity, dogeaiPrice),
            TokenInfo("Mock dogwifhat", "MWIF", 18, 1_000_000 * 10**18, wifLiquidity, wifPrice),
            TokenInfo("Mock STONKS", "MSTONKS", 18, 1_000_000 * 10**18, stonksLiquidity, stonksPrice)
        ];

        for (uint256 i = 0; i < tokens.length; i++) {
            address tokenAddress = factory.createToken(
                tokens[i].name,
                tokens[i].symbol,
                tokens[i].initialSupply,
                tokens[i].decimals,
                tokens[i].initialPrice
            );

            MockToken token = MockToken(tokenAddress);
            vm.label(tokenAddress, tokens[i].name);
            console.log("Token", tokens[i].name, "deployed at:", tokenAddress);

            // Approve and set liquidity
            token.approve(address(core), tokens[i].liquidity);
            core.addLiquidity(tokenAddress, tokens[i].liquidity);
            console.log("Liquidity set for", tokens[i].name, ":", tokens[i].liquidity);
        }

        vm.stopBroadcast();
    }
}