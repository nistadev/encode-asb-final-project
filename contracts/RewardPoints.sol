// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error NotAuthorized();
error RewardDoesNotExist();
error InsufficientTokens();
error NotEnoughTokensToRedeem();

struct Reward {
    uint256 id;    // Unique ID for the reward
    uint256 amount; // Amount of tokens needed to redeem the reward
    bool exists;   // To check if the reward exists
}

contract CreatorPoints is ERC20 {
    address public platformAddress;
    address public creatorAddress;
    uint256 public rewardCounter; // Counter for unique reward IDs
    mapping(uint256 => Reward) public rewards; // Mapping to store rewards by ID

    constructor(address _platformAddress, address _creatorAddress) 
        ERC20("CreatorPoints", "CPT") 
    {
        platformAddress = _platformAddress;
        creatorAddress = _creatorAddress;
        rewardCounter = 0; // Initialize counter
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == platformAddress || msg.sender == creatorAddress,
            NotAuthorized()
        );
        _;
    }

    function rewardUser(address user, uint256 amount) external onlyAuthorized {
        _mint(user, amount);
    }

    function burnPoints(address user, uint256 amount) external onlyAuthorized {
        _burn(user, amount);
    }

    // Create a new reward
    function createReward(uint256 id, uint256 amount) external onlyAuthorized {
        require(!rewards[id].exists, "Reward ID already exists."); // Check if the reward ID is unique
        rewards[id] = Reward({
            id: id,
            amount: amount,
            exists: true
        });
    }

    // Retrieve a reward by ID
    function getReward(uint256 id) external view returns (Reward memory) {
        Reward memory reward = rewards[id];
        require(reward.exists, "Reward does not exist.");
        return reward;
    }

    // Update an existing reward
    function updateReward(uint256 id, uint256 amount) external onlyAuthorized {
        Reward storage reward = rewards[id];
        require(reward.exists, "Reward does not exist.");

        reward.amount = amount;
    }

    // Delete a reward by ID
    function deleteReward(uint256 id) external onlyAuthorized {
        Reward storage reward = rewards[id];
        require(reward.exists, "Reward does not exist.");

        delete rewards[id];
    }

    // Redeem a reward by ID
    function redeemReward(uint256 rewardId) external {
        Reward memory reward = rewards[rewardId];
        require(reward.exists, "Reward does not exist.");
        
        // Check if the user has enough tokens
        uint256 userBalance = balanceOf(msg.sender);
        require(userBalance >= reward.amount, "Not enough tokens to redeem this reward.");

        // Burn the user's points
        _burn(msg.sender, reward.amount);

        // Transfer the equivalent amount to the creator
        _mint(creatorAddress, reward.amount);

        // Emit an event (optional, can be useful for tracking)
        emit RewardRedeemed(msg.sender, rewardId, reward.amount);
    }

    event RewardRedeemed(address indexed user, uint256 rewardId, uint256 amount);
}
