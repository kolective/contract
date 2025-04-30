// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    uint8 private _decimals;
    uint256 public price;
    address public owner;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimals_,
        uint256 initialPrice,
        address owner_
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        owner = owner_;
        price = initialPrice;
        _mint(owner_, initialSupply * (10 ** uint256(decimals_)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setPriceInUSD(uint256 newPrice) external {
        price = newPrice;
    }

    function getPriceInUSD() external view returns (uint256) {
        return price;
    }
}
