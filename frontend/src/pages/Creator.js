import React, { useState } from "react";
import creatorPointsAbi from "../abi/CreatorPoints.json";
import { ethers } from "ethers"; // Directly import from ethers v6
import { REWARDS_ADDRESS } from "../constants";

const Creator = ({ signer }) => {
  const [pointsAmount, setPointsAmount] = useState("");
  const [userAddress, setUserAddress] = useState(""); // New state for user address
  const [rewardAmount, setRewardAmount] = useState(""); // New state for reward amount
  const [rewardDescription, setRewardDescription] = useState(""); // New state for reward description

  // Function to mint reward points for the user
  const mintRewardPoints = async () => {
    try {
      const creatorPointsContract = new ethers.Contract(
        REWARDS_ADDRESS, // Replace with your contract address
        creatorPointsAbi,
        signer
      );
      const tx = await creatorPointsContract.mintPoints(userAddress, pointsAmount);
      await tx.wait();
      alert("Points minted successfully!");
      setPointsAmount(""); // Clear input after minting
      setUserAddress(""); // Clear user address after minting
    } catch (error) {
      console.error("Error minting points:", error);
      alert("Error minting points");
    }
  };

  // Function to create a new reward
  const createReward = async () => {
    try {
      const creatorPointsContract = new ethers.Contract(
        REWARDS_ADDRESS, // Replace with your contract address
        creatorPointsAbi,
        signer
      );
      // Call the function to create a reward in the contract
      const tx = await creatorPointsContract.createReward(rewardDescription, rewardAmount);
      await tx.wait();
      alert("Reward created successfully!");
      setRewardAmount(""); // Clear input after creating
      setRewardDescription(""); // Clear description after creating
    } catch (error) {
      console.error("Error creating reward:", error);
      alert("Error creating reward");
    }
  };

  return (
    <div className="flex flex-col items-center p-8 bg-gray-100 min-h-screen bg-gradient-to-r from-purple-300 to-blue-400">
      <h2 className="text-3xl font-bold mb-6 text-gray-800">Creator Dashboard</h2>

      {/* Mint Reward Points Section */}
      <div className="mb-6 bg-white shadow-md rounded-lg p-6 w-full max-w-md">
        <h3 className="text-2xl font-semibold mb-4 text-gray-800">Mint Points for User</h3>
        <label className="block mb-4">
          User Address:
          <input
            type="text"
            value={userAddress}
            onChange={(e) => setUserAddress(e.target.value)}
            placeholder="Enter User Address"
            className="border border-gray-300 rounded-lg p-2 w-full"
          />
        </label>
        <label className="block mb-4">
          Points Amount:
          <input
            type="number"
            value={pointsAmount}
            onChange={(e) => setPointsAmount(e.target.value)}
            placeholder="Points Amount"
            className="border border-gray-300 rounded-lg p-2 w-full"
          />
        </label>
        <button
          onClick={mintRewardPoints}
          className="bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-lg"
        >
          Mint Points
        </button>
      </div>

      {/* Create Reward Section */}
      <div className="mb-6 bg-white shadow-md rounded-lg p-6 w-full max-w-md">
        <h3 className="text-2xl font-semibold mb-4 text-gray-800">Create Reward</h3>
        <label className="block mb-4">
          Reward Description:
          <input
            type="text"
            value={rewardDescription}
            onChange={(e) => setRewardDescription(e.target.value)}
            placeholder="Enter Reward Description"
            className="border border-gray-300 rounded-lg p-2 w-full"
          />
        </label>
        <label className="block mb-4">
          Reward Amount (in RewardPoints):
          <input
            type="number"
            value={rewardAmount}
            onChange={(e) => setRewardAmount(e.target.value)}
            placeholder="Amount of Reward Points"
            className="border border-gray-300 rounded-lg p-2 w-full"
          />
        </label>
        <button
          onClick={createReward}
          className="bg-green-600 hover:bg-green-700 text-white py-2 px-4 rounded-lg"
        >
          Create Reward
        </button>
      </div>
    </div>
  );
};

export default Creator;
