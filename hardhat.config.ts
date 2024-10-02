import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.27",
    settings: {
      viaIR: true, // Enable the via-IR pipeline
      optimizer: {
        enabled: true,
        runs: 100,
      },
    },
  },
};

export default config;
