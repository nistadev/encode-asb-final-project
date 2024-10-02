// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import {Script} from "forge-std/Script.sol";
import {SubscriptionLogic} from "../contracts/Subscription.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeploySubscriptionLogic is Script {
    SubscriptionLogic private s_subscription;

    function run() external returns (SubscriptionLogic) {
        vm.startBroadcast();
        s_subscription = new SubscriptionLogic({
            _platformToken: IERC20(address(1)),
            _platformAddress: address(2),
            _platformFee: 250,
            tier1Price: 0.02 ether,
            tier2Price: 0.01 ether,
            tier3Price: 0.005 ether
        });
        vm.stopBroadcast();
        return s_subscription;
    }
}