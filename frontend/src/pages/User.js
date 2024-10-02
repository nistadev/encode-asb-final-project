import React, { useState, useEffect } from "react";
import { parseUnits, ethers } from "ethers"; // Directly import from ethers.js v6
import subscriptionAbi from "../abi/SubscriptionLogic.json";
import creatorPointsAbi from "../abi/CreatorPoints.json";

const User = ({ signer }) => {
  const [tier, setTier] = useState(1);
  const [creatorAddress, setCreatorAddress] = useState(""); // New state for creator address
  const [availablePoints, setAvailablePoints] = useState(0); // New state for available points
  const [rewardDescription, setRewardDescription] = useState(""); // New state for reward description
  const [rewardAmount, setRewardAmount] = useState(""); // New state for reward amount

  // Function to fetch available points
  const fetchAvailablePoints = async () => {
    try {
      const creatorPointsContract = new ethers.Contract(
        "0xYourCreatorPointsContractAddress", // Replace with your contract address
        creatorPointsAbi,
        signer
      );
      const points = await creatorPointsContract.balanceOf(signer.address); // Get user's available points
      setAvailablePoints(points.toString());
    } catch (error) {
      console.error("Error fetching available points:", error);
    }
  };

  useEffect(() => {
    fetchAvailablePoints();
  }, [signer]); // Fetch points when signer changes

  // Function to subscribe to a creator's tier
  const subscribeToTier = async () => {
    try {
      const subscriptionContract = new ethers.Contract(
        "0xe4eC5E2A324bBBe80b2d80735D843112C69F5b05", // Replace with your contract address
        subscriptionAbi,
        signer
      );
      const tx = await subscriptionContract.subscribe(tier, {
        from: signer.address,
      });
      await tx.wait();
      alert("Subscription successful!");
    } catch (error) {
      console.error("Error subscribing to tier:", error);
      alert("Error subscribing");
    }
  };

  // Function to redeem all available reward points
  const redeemAllPoints = async () => {
    try {
      const creatorPointsContract = new ethers.Contract(
        "0xYourCreatorPointsContractAddress", // Replace with your contract address
        creatorPointsAbi,
        signer
      );

      const tx = await creatorPointsContract.burnPoints(availablePoints);
      await tx.wait();
      alert("All points redeemed successfully!");
      setAvailablePoints(0); // Reset available points after redeeming
    } catch (error) {
      console.error("Error redeeming points:", error);
      alert("Error redeeming points");
    }
  };

  // Function to redeem a reward from the selected creator
  const redeemReward = async () => {
    try {
      const creatorPointsContract = new ethers.Contract(
        "0xYourCreatorPointsContractAddress", // Replace with your contract address
        creatorPointsAbi,
        signer
      );

      const tx = await creatorPointsContract.redeemReward(
        creatorAddress,
        rewardDescription
      );
      await tx.wait();
      alert("Reward redeemed successfully!");
      setRewardDescription(""); // Clear input after redeeming
    } catch (error) {
      console.error("Error redeeming reward:", error);
      alert("Error redeeming reward");
    }
  };

  return (
    <div className="flex flex-col items-center p-8 bg-gray-100 min-h-screen bg-gradient-to-r from-purple-300 to-blue-400">
      <h2 className="text-3xl font-bold mb-6 text-gray-800">User Dashboard</h2>

      {/* Subscribe to a Creator */}
      <div className="mb-6 bg-white shadow-md rounded-lg p-6 w-full max-w-md">
        <h3 className="text-2xl font-semibold mb-4 text-gray-800">
          Subscribe to Creator
        </h3>
        <label className="block mb-4">
          Creator Address:
          <input
            type="text"
            value={creatorAddress}
            onChange={(e) => setCreatorAddress(e.target.value)}
            placeholder="Enter Creator Address"
            className="border border-gray-300 rounded-lg p-2 w-full"
          />
        </label>
        <label className="block mb-4">
          Select Tier:
          <select
            value={tier}
            onChange={(e) => setTier(Number(e.target.value))}
            className="border border-gray-300 rounded-lg p-2 w-full"
          >
            <option value={1}>Tier 1</option>
            <option value={2}>Tier 2</option>
            <option value={3}>Tier 3</option>
          </select>
        </label>
        <button
          onClick={subscribeToTier}
          className="bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-lg"
        >
          Subscribe
        </button>
      </div>

      {/* Redeem Points Section */}
      <div className="mb-6 bg-white shadow-md rounded-lg p-6 w-full max-w-md">
        <h3 className="text-2xl font-semibold mb-4 text-gray-800">
          Redeem Points
        </h3>
        <p className="mb-2">Available Points: {availablePoints}</p>
        <button
          onClick={redeemAllPoints}
          className="bg-green-600 hover:bg-green-700 text-white py-2 px-4 rounded-lg"
        >
          Redeem All Points
        </button>
      </div>

      {/* Redeem Reward Section */}
      <div className="mb-6 bg-white shadow-md rounded-lg p-6 w-full max-w-md">
        <h3 className="text-2xl font-semibold mb-4 text-gray-800">
          Redeem Reward
        </h3>
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
        <button
          onClick={redeemReward}
          className="bg-purple-600 hover:bg-purple-700 text-white py-2 px-4 rounded-lg"
        >
          Redeem Reward
        </button>
      </div>
    </div>
  );
};

export default User;
