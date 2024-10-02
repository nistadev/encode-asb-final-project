// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

enum Tier {
    Tier1,
    Tier2,
    Tier3,
    None
}

struct Subscription {
    Tier tier;
    bool isActive;
    uint256 nextPaymentDue;
    uint256 lastPaymentAmount;
}

error SubscriptionNotActive();
error InvalidTier();
error PaymentNotDue();
error NotACreator();
error InvalidCreatorAddress();

contract SubscriptionLogic {
    uint256 public constant ONE_MONTH = 30 days;

    IERC20 public platformToken;
    address public platformAddress;
    uint256 public platformFee; // In basis points (e.g., 500 = 5%)
    
    // Creator mapping
    mapping(address => bool) public creators;
    mapping(address => Subscription) public subscriptions;
    mapping(Tier => uint256) public tierPrices;
    mapping(address => uint256) public creatorBalances; // Store balances for creators

    event Subscribed(address indexed user, Tier indexed tier, uint256 amount);
    event Renewed(address indexed user, Tier indexed tier, uint256 amount);
    event SubscriptionExpired(address indexed user);
    event CreatorAdded(address indexed creator);
    event FeesWithdrawn(address indexed creator, uint256 amount);

    constructor(
        IERC20 _platformToken,
        address _platformAddress,
        uint256 _platformFee,
        uint256 tier1Price,
        uint256 tier2Price,
        uint256 tier3Price
    ) {
        platformToken = _platformToken;
        platformAddress = _platformAddress;
        platformFee = _platformFee;

        // Set tier prices (for example: 10, 20, and 50 tokens for tiers 1, 2, and 3)
        tierPrices[Tier.Tier1] = tier1Price;
        tierPrices[Tier.Tier2] = tier2Price;
        tierPrices[Tier.Tier3] = tier3Price;
    }

    modifier onlyActive(address user) {
        require(subscriptions[user].isActive, SubscriptionNotActive());
        _;
    }

    modifier onlyCreator() {
        require(creators[msg.sender], NotACreator());
        _;
    }

    function subscribe(Tier _tier) external {
        require(uint8(_tier) < uint8(Tier.None), InvalidTier());

        uint256 price = tierPrices[_tier];

        _applyFee(price);

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
        require(block.timestamp >= sub.nextPaymentDue, PaymentNotDue());

        uint256 price = sub.lastPaymentAmount;

        _applyFee(price);

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

    // Function to add a creator
    function addCreator(address creator) external {
        require(creator != address(0), "Invalid creator address");
        creators[creator] = true;
        emit CreatorAdded(creator);
    }

    function setPlatformFee(uint256 newFee) external {
        // Access control: Only platform admin can change the fee
        platformFee = newFee;
    }

    function setTierPrice(Tier _tier, uint256 newPrice) external {
        // Access control: Only platform admin can change tier prices
        tierPrices[_tier] = newPrice;
    }

    function _applyFee(uint256 price) internal {
        // Transfer the subscription fee
        uint256 feeAmount = (price * platformFee) / 10000;
        uint256 creatorAmount = price - feeAmount;

        platformToken.transferFrom(msg.sender, platformAddress, feeAmount);
        creatorBalances[msg.sender] += creatorAmount; // Accumulate creator's earnings
    }

    // Function for creators to withdraw their fees
    function withdrawFees() external onlyCreator {
        uint256 amount = creatorBalances[msg.sender];
        require(amount > 0, "No fees to withdraw");

        creatorBalances[msg.sender] = 0; // Reset the balance before transfer
        platformToken.transfer(msg.sender, amount); // Transfer the tokens to the creator

        emit FeesWithdrawn(msg.sender, amount);
    }
}
