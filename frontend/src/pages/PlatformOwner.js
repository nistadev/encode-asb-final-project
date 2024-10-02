import React, { useState } from 'react';
import { parseUnits, ethers } from 'ethers'; // Directly import from ethers v6
import subscriptionAbi from '../abi/SubscriptionLogic.json';
import { SUBSCRIPTION_ADDRESS } from '../constants';

const PlatformOwner = ({ signer }) => {
  const [tierPrice, setTierPrice] = useState('');
  const [selectedTier, setSelectedTier] = useState(1); // Default to Tier 1
  const [newCreatorAddress, setNewCreatorAddress] = useState('');

  // Function to set the price of a subscription tier
  const setSubscriptionTierPrice = async () => {
    try {
      const contract = new ethers.Contract(
        SUBSCRIPTION_ADDRESS, // Replace with your contract address
        subscriptionAbi,
        signer
      );

      const tx = await contract.setTierPrice(selectedTier - 1, parseUnits(tierPrice, 'ether'));
      await tx.wait();
      alert('Tier price updated!');
    } catch (error) {
      console.error('Error setting tier price:', error);
      alert('Error updating tier price');
    }
  };

  // Function to add a new creator
  const addCreator = async () => {
    try {
      const contract = new ethers.Contract(
        SUBSCRIPTION_ADDRESS, // Replace with your contract address
        subscriptionAbi,
        signer
      );

      const tx = await contract.addCreator(newCreatorAddress);
      await tx.wait();
      alert('Creator added successfully!');
      setNewCreatorAddress(''); // Clear the input field after adding
    } catch (error) {
      console.error('Error adding creator:', error);
      alert('Error adding creator');
    }
  };

  return (
    <div className="flex flex-col items-center p-8 bg-gray-100 min-h-screen bg-gradient-to-r from-purple-300 to-blue-400">
      <h2 className="text-3xl font-bold mb-6 text-gray-800">Platform Owner Dashboard</h2>

      <div className="mb-6 bg-white shadow-md rounded-lg p-6 w-full max-w-md">
        <label className="block mb-4">
          Set Tier Price (in ETH):
          <input
            type="number"
            value={tierPrice}
            onChange={(e) => setTierPrice(e.target.value)}
            placeholder="Tier Price"
            className="border border-gray-300 rounded-lg p-2 w-full"
          />
        </label>

        <label className="block mb-4">
          Select Tier:
          <select
            value={selectedTier}
            onChange={(e) => setSelectedTier(Number(e.target.value))}
            className="border border-gray-300 rounded-lg p-2 w-full"
          >
            <option value={1}>Tier 1</option>
            <option value={2}>Tier 2</option>
            <option value={3}>Tier 3</option>
          </select>
        </label>

        <button
          onClick={setSubscriptionTierPrice}
          className="bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-lg"
        >
          Set Tier Price
        </button>
      </div>

      <div className="mb-6 bg-white shadow-md rounded-lg p-6 w-full max-w-md">
        <h3 className="text-2xl font-semibold mb-4 text-gray-800">Add Creator</h3>
        <label className="block mb-4">
          Creator Address:
          <input
            type="text"
            value={newCreatorAddress}
            onChange={(e) => setNewCreatorAddress(e.target.value)}
            placeholder="Enter Creator Address"
            className="border border-gray-300 rounded-lg p-2 w-full"
          />
        </label>
        <button
          onClick={addCreator}
          className="bg-green-600 hover:bg-green-700 text-white py-2 px-4 rounded-lg"
        >
          Add Creator
        </button>
      </div>
    </div>
  );
};

export default PlatformOwner;
