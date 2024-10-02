// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/SubscriptionLogic.sol";
import "../src/CreatorPoints.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/SubscriptionLogicV2.sol";
import "../src/Proxy.sol";


contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MCK") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract SubscriptionTest is Test {
    SubscriptionLogic implementation;
    TransparentUpgradeableProxy proxy;
    ProxyAdmin proxyAdmin;
    CreatorPoints creatorPoints;
    MockERC20 mockToken;
    SafeDeployment safedeployment;
    address admin = address(1);
    address user1 = address(2);
    address user2 = address(3);
    address creator = address(4);

    uint256 constant PLATFORM_FEE = 500; // 5%

    function setUp() public {
        vm.startPrank(admin);
        mockToken = new MockERC20();
        implementation = new SubscriptionLogic();
        safedeployment = new SafeDeployment();

        bytes memory initData = abi.encodeWithSelector(
            SubscriptionLogic.initialize.selector,
            IERC20(address(mockToken)),
            admin,
            creator,
            PLATFORM_FEE
        );

        // proxy = new TransparentUpgradeableProxy(
        //     address(implementation),
        //     admin,
        //     initData
        // );
        (address proxyAddress, address proxyAdminAddress) = safedeployment.deployProxy(address(implementation), admin, initData);
        proxy = TransparentUpgradeableProxy(payable(proxyAddress));
        proxyAdmin = ProxyAdmin(proxyAdminAddress);

        creatorPoints = new CreatorPoints(address(proxy), creator);

        mockToken.transfer(user1, 1000 ether);
        mockToken.transfer(user2, 1000 ether);

        vm.stopPrank();

        vm.prank(user1);
        mockToken.approve(address(proxy), type(uint256).max);

        vm.prank(user2);
        mockToken.approve(address(proxy), type(uint256).max);
    }

    function testSubscribe() public {
        vm.prank(user1);
        SubscriptionLogic(address(proxy)).subscribe(SubscriptionLogic.Tier.Tier1);
        
        (SubscriptionLogic.Tier tier, uint256 nextPaymentDue, uint256 lastPaymentAmount, bool isActive) = 
            SubscriptionLogic(address(proxy)).subscriptions(user1);
        
        assertEq(uint(tier), uint(SubscriptionLogic.Tier.Tier1));
        assertEq(lastPaymentAmount, 0.01 ether);
        assertTrue(isActive);
        assertEq(nextPaymentDue, block.timestamp + 30 days);
    }

    function testRenewSubscription() public {
        testSubscribe();
        
        vm.warp(block.timestamp + 30 days);
        vm.prank(user1);
        SubscriptionLogic(address(proxy)).renewSubscription();
        
        (, uint256 nextPaymentDue, , bool isActive) = 
            SubscriptionLogic(address(proxy)).subscriptions(user1);
        
        assertTrue(isActive);
        assertEq(nextPaymentDue, block.timestamp + 30 days);
    }

    function testCancelSubscription() public {
        testSubscribe();
        
        vm.prank(user1);
        SubscriptionLogic(address(proxy)).cancelSubscription();
        
        (, , , bool isActive) = SubscriptionLogic(address(proxy)).subscriptions(user1);
        assertFalse(isActive);
    }

    function testCheckSubscriptionStatus() public {
        testSubscribe();
        
        bool status = SubscriptionLogic(address(proxy)).checkSubscriptionStatus(user1);
        assertTrue(status);
        
        vm.warp(block.timestamp + 31 days);
        status = SubscriptionLogic(address(proxy)).checkSubscriptionStatus(user1);
        assertFalse(status);
    }

    function testSetPlatformFee() public {
        uint256 newFee = 600; // 6%
        vm.prank(creator);
        SubscriptionLogic(address(proxy)).setPlatformFee(newFee);
        assertEq(SubscriptionLogic(address(proxy)).platformFee(), newFee);
    }

    function testSetTierPrice() public {
        uint256 newPrice = 0.02 ether;
        vm.prank(creator);
        SubscriptionLogic(address(proxy)).setTierPrice(SubscriptionLogic.Tier.Tier1, newPrice);
        assertEq(SubscriptionLogic(address(proxy)).tierPrices(SubscriptionLogic.Tier.Tier1), newPrice);
    }

    function testUpgradeImplementation() public {
        SubscriptionLogicV2 newImplementation = new SubscriptionLogicV2();
        uint256 NEW_PLATFORM_FEE = 1000;

        bytes memory initData = abi.encodeWithSelector(
            SubscriptionLogicV2.initialize.selector,
            IERC20(address(mockToken)),
            admin,
            creator,
            NEW_PLATFORM_FEE
        );
        
        vm.prank(admin);
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(payable(address(proxy))), address(newImplementation), initData);

        // Test new function from V2
        assertEq(SubscriptionLogicV2(address(proxy)).newFunction(), 42);

        assertEq(SubscriptionLogicV2(address(proxy)).platformFee(), NEW_PLATFORM_FEE);

    }

    function testRewardPoints() public {
        uint256 rewardAmount = 100;
        vm.prank(creator);
        creatorPoints.rewardUser(user1, rewardAmount);
        assertEq(creatorPoints.balanceOf(user1), rewardAmount);
    }

    function testBurnPoints() public {
        testRewardPoints();
        uint256 burnAmount = 50;

        vm.prank(creator);
        creatorPoints.burnPoints(user1, burnAmount);
        assertEq(creatorPoints.balanceOf(user1), 50);
    }

    function testFailSubscribeInsufficientBalance() public {
        vm.startPrank(user2);
        mockToken.transfer(address(0), mockToken.balanceOf(user2)); // Drain balance
        vm.expectRevert("Insufficient balance");
        SubscriptionLogic(address(proxy)).subscribe(SubscriptionLogic.Tier.Tier1);
        vm.stopPrank();
    }

    function testFailRenewSubscriptionNotDue() public {
        testSubscribe();
        vm.prank(user1);
        vm.expectRevert("Payment not due yet");
        SubscriptionLogic(address(proxy)).renewSubscription();
    }

    function testFailCancelInactiveSubscription() public {
        vm.prank(user2);
        vm.expectRevert("Subscription not active");
        SubscriptionLogic(address(proxy)).cancelSubscription();
    }

    function testSubscribeDifferentTiers() public {
        vm.startPrank(user1);
        SubscriptionLogic(address(proxy)).subscribe(SubscriptionLogic.Tier.Tier2);
        
        (SubscriptionLogic.Tier tier, , uint256 lastPaymentAmount, ) = 
            SubscriptionLogic(address(proxy)).subscriptions(user1);
        
        assertEq(uint(tier), uint(SubscriptionLogic.Tier.Tier2));
        assertEq(lastPaymentAmount, 0.1 ether);
        vm.stopPrank();
    }

    function testFeeDistribution() public {
        uint256 initialPlatformBalance = mockToken.balanceOf(admin);
        uint256 initialCreatorBalance = mockToken.balanceOf(creator);
        
        testSubscribe();
        
        uint256 expectedPlatformFee = (0.01 ether * PLATFORM_FEE) / 10000;
        uint256 expectedCreatorPayment = 0.01 ether - expectedPlatformFee;
        
        assertEq(mockToken.balanceOf(admin) - initialPlatformBalance, expectedPlatformFee);
        assertEq(mockToken.balanceOf(address(proxy)) - initialCreatorBalance, expectedCreatorPayment);
    }

    function testWithdrawCreatorFunds() public {
        testSubscribe();
        
        uint256 initialCreatorBalance = mockToken.balanceOf(creator);
        uint256 expectedCreatorPayment = 0.01 ether - ((0.01 ether * PLATFORM_FEE) / 10000);
        
        vm.prank(creator);
        SubscriptionLogic(address(proxy)).withdrawCreatorFunds();
        
        assertEq(mockToken.balanceOf(creator) - initialCreatorBalance, expectedCreatorPayment);
    }

    function testOnlyCreatorCanChangeFee() public {
        vm.prank(user1);
        vm.expectRevert("Not authorized");
        SubscriptionLogic(address(proxy)).setPlatformFee(600);

        vm.prank(creator);
        SubscriptionLogic(address(proxy)).setPlatformFee(600);
        assertEq(SubscriptionLogic(address(proxy)).platformFee(), 600);
    }

    function testOnlyCreatorCanChangeTierPrice() public {
        vm.prank(user1);
        vm.expectRevert("Not authorized");
        SubscriptionLogic(address(proxy)).setTierPrice(SubscriptionLogic.Tier.Tier1, 0.02 ether);

        vm.prank(creator);
        SubscriptionLogic(address(proxy)).setTierPrice(SubscriptionLogic.Tier.Tier1, 0.02 ether);
        assertEq(SubscriptionLogic(address(proxy)).tierPrices(SubscriptionLogic.Tier.Tier1), 0.02 ether);
    }
}