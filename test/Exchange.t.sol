// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Exchange.sol";
import "../contracts/Erc20Example.sol";

contract TokenExchangeTest is Test {
    TokenExchange public exchange;
    Erc20Example public token;
    
    address public owner = address(1);
    address public user = address(2);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy token
        token = new Erc20Example();
        
        // Deploy exchange with 1000 tokens per ETH rate
        exchange = new TokenExchange(address(token), 1000 * 10**18, owner);
        
        // Add liquidity to exchange
        token.transfer(address(exchange), 10000 * 10**18); // Token liquidity
        vm.deal(address(exchange), 10 ether); // ETH liquidity
        
        vm.stopPrank();
        
        // Setup user
        vm.deal(user, 10 ether);
        vm.startPrank(user);
        token.approve(address(exchange), type(uint256).max);
        vm.stopPrank();
    }
    
    function testBuyTokens() public {
        vm.startPrank(user);
        
        uint256 initialTokenBalance = token.balanceOf(user);
        uint256 initialEthBalance = user.balance;
        
        exchange.buyTokens{value: 1 ether}();
        
        assertEq(token.balanceOf(user), initialTokenBalance + 1000 * 10**18);
        assertEq(user.balance, initialEthBalance - 1 ether);
        
        vm.stopPrank();
    }
    
    function testSellTokens() public {
        // First buy some tokens
        vm.startPrank(user);
        exchange.buyTokens{value: 1 ether}();
        
        uint256 initialTokenBalance = token.balanceOf(user);
        uint256 initialEthBalance = user.balance;
        
        // Then sell half of them
        exchange.sellTokens(500 * 10**18);
        
        assertEq(token.balanceOf(user), initialTokenBalance - 500 * 10**18);
        assertEq(user.balance, initialEthBalance + 0.5 ether);
        
        vm.stopPrank();
    }
}