// src/components/ConnectWallet.js

import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import SubscriptionLogic from "../abi/SubscriptionLogic.json"; // Ensure the ABI path is correct
import { useNavigate } from "react-router-dom";
import { SUBSCRIPTION_ADDRESS } from "../constants";

const ConnectWallet = ({ onSignerChanged }) => {
  const [userAddress, setUserAddress] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const checkUserRole = async () => {
      if (!userAddress) return;

      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(
        SUBSCRIPTION_ADDRESS,
        SubscriptionLogic.abi,
        signer
      );

      onSignerChanged(signer);

      // Get platform owner address
      const platformOwnerAddress = await contract.getPlatformAddress();

      // Check if the user is the platform owner
      if (userAddress.toLowerCase() === platformOwnerAddress.toLowerCase()) {
        navigate("/owner"); // Redirect to platform owner page
      } else {
        // Check if user is a creator
        const isCreator = await contract.addressIsCreator(userAddress);
        if (isCreator) {
          navigate("/creator"); // Redirect to creator page
        } else {
          navigate("/user"); // Redirect to user page
        }
      }
    };

    checkUserRole();
  }, [userAddress, navigate]);

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        setUserAddress(accounts[0]);
      } catch (error) {
        console.error("Error connecting to wallet: ", error);
      }
    } else {
      alert("Please install MetaMask!");
    }
  };

  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gradient-to-r from-purple-300 to-blue-400 text-white">
      <h2 className="text-3xl font-bold mb-5">Connect Your Wallet</h2>
      <button
        onClick={connectWallet}
        className="px-6 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition duration-300 focus:outline-none focus:ring focus:ring-blue-300"
      >
        Connect Wallet
      </button>
      {userAddress && <p className="mt-5">Connected as: {userAddress}</p>}
    </div>
  );
};

export default ConnectWallet;
