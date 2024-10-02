// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "../src/Proxy.sol";
// import "../src/SubscriptionLogic.sol";
// import "../src/CreatorPoints.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract MockERC20 is ERC20 {
//     constructor() ERC20("Mock Token", "MCK") {
//         _mint(msg.sender, 1000000 * 10**18);
//     }
// }

// contract SubscriptionTest is Test {
//     Proxy proxy;
//     SubscriptionLogic logic;
//     CreatorPoints creatorPoints;
//     MockERC20 mockToken;

//     address admin = address(1);
//     address user1 = address(2);
//     address user2 = address(3);
//     address creator = address(4);

//     uint256 constant PLATFORM_FEE = 500; // 5%

//     function setUp() public {
//         vm.startPrank(admin);
//         mockToken = new MockERC20();
//         logic = new SubscriptionLogic(IERC20(address(mockToken)), admin, PLATFORM_FEE);
//         proxy = new Proxy(address(logic));
//         creatorPoints = new CreatorPoints(address(proxy), creator);
//         vm.stopPrank();

//         // Fund users
//         mockToken.transfer(user1, 1000 * 10**18);
//         mockToken.transfer(user2, 1000 * 10**18);
//     }

//     function testSubscribe() public {
//         vm.startPrank(user1);
//         mockToken.approve(address(proxy), type(uint256).max);
        
//         SubscriptionLogic(address(proxy)).subscribe(SubscriptionLogic.Tier.Tier1);
        
//         (SubscriptionLogic.Tier tier, uint256 nextPaymentDue, uint256 lastPaymentAmount, bool isActive) = 
//             SubscriptionLogic(address(proxy)).subscriptions(user1);
        
//         assertEq(uint(tier), uint(SubscriptionLogic.Tier.Tier1));
//         assertEq(lastPaymentAmount, 0.01 ether);
//         assertTrue(isActive);
//         assertEq(nextPaymentDue, block.timestamp + 30 days);
//         vm.stopPrank();
//     }

//     function testRenewSubscription() public {
//         testSubscribe();
        
//         vm.warp(block.timestamp + 30 days);
//         vm.prank(user1);
//         SubscriptionLogic(address(proxy)).renewSubscription();
        
//         (, uint256 nextPaymentDue, , bool isActive) = 
//             SubscriptionLogic(address(proxy)).subscriptions(user1);
        
//         assertTrue(isActive);
//         assertEq(nextPaymentDue, block.timestamp + 30 days);
//     }

//     function testCancelSubscription() public {
//         testSubscribe();
        
//         vm.prank(user1);
//         SubscriptionLogic(address(proxy)).cancelSubscription();
        
//         (, , , bool isActive) = SubscriptionLogic(address(proxy)).subscriptions(user1);
//         assertFalse(isActive);
//     }

//     function testCheckSubscriptionStatus() public {
//         testSubscribe();
        
//         bool status = SubscriptionLogic(address(proxy)).checkSubscriptionStatus(user1);
//         assertTrue(status);
        
//         vm.warp(block.timestamp + 31 days);
//         status = SubscriptionLogic(address(proxy)).checkSubscriptionStatus(user1);
//         assertFalse(status);
//     }

//     function testSetPlatformFee() public {
//         uint256 newFee = 600; // 6%
//         vm.prank(admin);
//         SubscriptionLogic(address(proxy)).setPlatformFee(newFee);
//         assertEq(SubscriptionLogic(address(proxy)).platformFee(), newFee);
//     }

//     function testSetTierPrice() public {
//         uint256 newPrice = 0.02 ether;
//         vm.prank(admin);
//         SubscriptionLogic(address(proxy)).setTierPrice(SubscriptionLogic.Tier.Tier1, newPrice);
//         assertEq(SubscriptionLogic(address(proxy)).tierPrices(SubscriptionLogic.Tier.Tier1), newPrice);
//     }

//     function testUpgradeImplementation() public {
//         SubscriptionLogic newLogic = new SubscriptionLogic(IERC20(address(mockToken)), admin, PLATFORM_FEE);
//         vm.prank(admin);
//         proxy.upgradeImplementation(address(newLogic));
//         assertEq(proxy.implementation(), address(newLogic));
//     }

//     function testRewardPoints() public {
//         uint256 rewardAmount = 100;
//         vm.prank(admin);
//         creatorPoints.rewardUser(user1, rewardAmount);
//         assertEq(creatorPoints.balanceOf(user1), rewardAmount);
//     }

//     function testBurnPoints() public {
//         testRewardPoints();
//         uint256 burnAmount = 50;
//         vm.prank(admin);
//         creatorPoints.burnPoints(user1, burnAmount);
//         assertEq(creatorPoints.balanceOf(user1), 50);
//     }

//     function testFailSubscribeInsufficientBalance() public {
//         vm.startPrank(user2);
//         mockToken.approve(address(proxy), type(uint256).max);
//         mockToken.transfer(address(0), mockToken.balanceOf(user2)); // Drain balance
//         vm.expectRevert("Insufficient balance");
//         SubscriptionLogic(address(proxy)).subscribe(SubscriptionLogic.Tier.Tier1);
//     }

//     function testFailRenewSubscriptionNotDue() public {
//         testSubscribe();
//         vm.prank(user1);
//         vm.expectRevert("Payment not due yet");
//         SubscriptionLogic(address(proxy)).renewSubscription();
//     }

//     function testFailCancelInactiveSubscription() public {
//         vm.prank(user2);
//         vm.expectRevert("Subscription not active");
//         SubscriptionLogic(address(proxy)).cancelSubscription();
//     }
// }