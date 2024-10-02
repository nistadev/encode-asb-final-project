import { ethers } from "hardhat";

async function main() {
  // Get the contract factory
  let signer = new ethers.Wallet(
    "0x0123456789012345678901234567890123456789012345678901234567890123",
    new ethers.JsonRpcProvider("https://rpc2.sepolia.org")
  );
  console.log("Signer: ", signer.address);
  // return;
  const Erc20 = (await ethers.getContractFactory("Erc20Example")).connect(
    signer
  );
  const erc20 = await Erc20.deploy({ gasLimit: 100000 });
  const erc20Address = await erc20.getAddress();
  console.log("Erc20: ", erc20Address);

  const Subscription = (
    await ethers.getContractFactory("SubscriptionLogic")
  ).connect(signer);
  const sub = await Subscription.deploy(
    erc20Address,
    erc20Address,
    500,
    1,
    2,
    5,
    { gasLimit: 100000 }
  );
  console.log("Subscription: ", await sub.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
