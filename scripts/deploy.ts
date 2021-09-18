import hre from "hardhat";
import { Sign } from "../typechain/Sign";
import { Sign__factory } from "../typechain/factories/Sign__factory";

async function main() {
  const Sign = await hre.ethers.getContractFactory("Sign") as Sign__factory;
  const sign = await Sign.deploy() as Sign;

  await sign.deployed();

  console.log("Sign deployed to:", sign.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
