import { ethers } from "hardhat";

async function main() {
  // Get the contract factory
  let signer = new ethers.Wallet(
    "0x0123456789012345678901234567890123456789012345678901234567890123",
    new ethers.JsonRpcProvider("https://rpc2.sepolia.org")
  );
  console.log("Signer: ", signer.address);
  // return;
  const Erc20 = (await ethers.getContractFactory("CreatorPoints")).connect(
    signer
  );
  const erc20 = await Erc20.deploy(
    "0x05c1124CD705264c60b833951C6D5890b92f53cb",
    "0xB6621b2fe9515C70638C0FE667cD396aC128DfE0",
    { gasLimit: 900000 }
  );
  const erc20Address = await erc20.getAddress();
  const ercResponse = await erc20.deploymentTransaction();
  let ercReceipt = await ercResponse!.wait();
  const ercGasUsed = ercReceipt?.gasUsed;
  console.log("GAS : ", ercGasUsed);
  console.log("Erc20: ", erc20Address);

  const Subscription = (
    await ethers.getContractFactory("SubscriptionLogic")
  ).connect(signer);
  const sub = await Subscription.deploy(
    "0xb2f902825D87efEE4E3eF6873b071F7FA86ca9aB",
    "0x05c1124CD705264c60b833951C6D5890b92f53cb",
    500,
    1,
    2,
    5,
    { gasLimit: 800000 }
  );
  const subResponse = await sub.deploymentTransaction();
  let receipt = await subResponse!.wait();
  const subGasUsed = receipt?.gasUsed;
  console.log("GAS : ", subGasUsed);
  console.log("Subscription: ", await sub.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
