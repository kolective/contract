// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockToken} from "./MockToken.sol";

contract TokenFactory {
    event TokenCreated(address indexed tokenAddress, string name, string symbol, uint256 initialSupply, uint8 decimals, uint256 initialPrice, address owner);

    function createToken(
        string memory name, 
        string memory symbol, 
        uint256 initialSupply,
        uint8 decimals,
        uint256 initialPrice
    ) external returns (address) {
        MockToken token = new MockToken(name, symbol, initialSupply, decimals, initialPrice, msg.sender);
        emit TokenCreated(address(token), name, symbol, initialSupply, decimals, initialPrice, msg.sender);
        return address(token);
    }
}
