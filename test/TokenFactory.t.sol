// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TokenFactory.sol";
import "../src/MockToken.sol";

contract TokenFactoryTest is Test {
    TokenFactory factory;

    function setUp() public {
        factory = new TokenFactory();
    }

    function testCreateToken() public {
        address tokenAddr = factory.createToken("Test Token", "TTK", 1_000, 18, 1e18);
        MockToken token = MockToken(tokenAddr);

        assertEq(token.name(), "Test Token");
        assertEq(token.symbol(), "TTK");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1_000 ether);
        assertEq(token.getPriceInUSD(), 1e18);
        assertEq(token.owner(), address(this));
    }
}
