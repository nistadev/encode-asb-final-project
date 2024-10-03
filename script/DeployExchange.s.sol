// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../contracts/Exchange.sol";
import "../contracts/Erc20Example.sol";

contract DeployExchange is Script {
    function run() external {
        // Retrieve private key from environment or use default test key
        uint256 deployerPrivateKey;
        try vm.envUint("PRIVATE_KEY") {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        } catch {
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }

        address deployerAddress = vm.addr(deployerPrivateKey);
        console.log("Deploying from address:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy platform token (or use existing token address on live networks)
        Erc20Example platformToken;
        try vm.envAddress("PLATFORM_TOKEN_ADDRESS") {
            platformToken = Erc20Example(vm.envAddress("PLATFORM_TOKEN_ADDRESS"));
            console.log("Using existing platform token at:", address(platformToken));
        } catch {
            platformToken = new Erc20Example();
            console.log("Deployed new platform token at:", address(platformToken));
        }

        // Set initial exchange rate: 100000 tokens per 1 ETH
        uint256 initialRate = 1000 * 10**18;
        
        // Deploy exchange contract
        TokenExchange exchange = new TokenExchange(
            address(platformToken),
            initialRate,
            deployerAddress
        );
        console.log("Deployed exchange contract at:", address(exchange));

        // Add initial liquidity
        uint256 initialTokenLiquidity = 10000 * 10**18; // 10,000 tokens
        uint256 initialEthLiquidity = 10 ether; // 10 ETH

        // Transfer initial token liquidity
        // platformToken.transfer(address(exchange), initialTokenLiquidity);
        // console.log("Transferred initial token liquidity:", initialTokenLiquidity);

        // // Transfer initial ETH liquidity
        // payable(address(exchange)).transfer(initialEthLiquidity);
        // console.log("Transferred initial ETH liquidity:", initialEthLiquidity);

        vm.stopBroadcast();

        // Log final setup
        console.log("\nDeployment Summary:");
        console.log("-------------------");
        console.log("Exchange Contract:", address(exchange));
        console.log("Platform Token:", address(platformToken));
        console.log("Initial Exchange Rate:", initialRate, "tokens per ETH");
        console.log("Initial Token Liquidity:", initialTokenLiquidity);
        console.log("Initial ETH Liquidity:", initialEthLiquidity);
    }
}