// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SubscriptionLogic {
    IERC20 public platformToken;
    address public platformAddress;
    uint256 public platformFee; // In basis points (e.g., 500 = 5%)

    enum Tier { None, Tier1, Tier2, Tier3 }

    struct Subscription {
        Tier tier;
        uint256 nextPaymentDue;
        uint256 lastPaymentAmount;
        bool isActive;
    }

    mapping(address => Subscription) public subscriptions;
    mapping(Tier => uint256) public tierPrices;

    uint256 public constant ONE_MONTH = 30 days;

    event Subscribed(address indexed user, Tier tier, uint256 amount);
    event Renewed(address indexed user, Tier tier, uint256 amount);
    event SubscriptionExpired(address indexed user);

    constructor(IERC20 _platformToken, address _platformAddress, uint256 _platformFee) {
        platformToken = _platformToken;
        platformAddress = _platformAddress;
        platformFee = _platformFee;
        
        // Set tier prices (for example: 10, 20, and 50 tokens for tiers 1, 2, and 3)
        tierPrices[Tier.Tier1] = 0.01 ether;
        tierPrices[Tier.Tier2] = 0.1 ether;
        tierPrices[Tier.Tier3] = 0.25 ether;
    }

    modifier onlyActive(address user) {
        require(subscriptions[user].isActive, "Subscription not active");
        _;
    }

    function subscribe(Tier _tier) external {
        require(_tier != Tier.None, "Invalid tier");
        
        uint256 price = tierPrices[_tier];
        require(platformToken.balanceOf(msg.sender) >= price, "Insufficient balance");

        // Transfer the subscription fee
        uint256 feeAmount = (price * platformFee) / 10000;
        uint256 creatorAmount = price - feeAmount;

        platformToken.transferFrom(msg.sender, platformAddress, feeAmount);
        platformToken.transferFrom(msg.sender, address(this), creatorAmount);

        subscriptions[msg.sender] = Subscription({
            tier: _tier,
            nextPaymentDue: block.timestamp + ONE_MONTH,
            lastPaymentAmount: price,
            isActive: true
        });

        emit Subscribed(msg.sender, _tier, price);
    }

    function renewSubscription() external onlyActive(msg.sender) {
        Subscription storage sub = subscriptions[msg.sender];
        require(block.timestamp >= sub.nextPaymentDue, "Payment not due yet");

        uint256 price = sub.lastPaymentAmount;
        require(platformToken.balanceOf(msg.sender) >= price, "Insufficient balance");

        uint256 feeAmount = (price * platformFee) / 10000;
        uint256 creatorAmount = price - feeAmount;

        platformToken.transferFrom(msg.sender, platformAddress, feeAmount);
        platformToken.transferFrom(msg.sender, address(this), creatorAmount);

        sub.nextPaymentDue = block.timestamp + ONE_MONTH;

        emit Renewed(msg.sender, sub.tier, price);
    }

    function checkSubscriptionStatus(address user) external view returns (bool) {
        Subscription memory sub = subscriptions[user];
        if (!sub.isActive || block.timestamp > sub.nextPaymentDue) {
            return false;
        }
        return true;
    }

    function cancelSubscription() external onlyActive(msg.sender) {
        subscriptions[msg.sender].isActive = false;
        emit SubscriptionExpired(msg.sender);
    }

    function setPlatformFee(uint256 newFee) external {
        // Access control: Only platform admin can change the fee
        platformFee = newFee;
    }

    function setTierPrice(Tier _tier, uint256 newPrice) external {
        // Access control: Only platform admin can change tier prices
        tierPrices[_tier] = newPrice;
    }
}
