import { expect } from "chai";
import { ethers } from "hardhat";
import { Sign } from "../typechain/Sign";
import { Sign__factory } from "../typechain/factories/Sign__factory";

describe("Sign", function () {
  it("Should deploy a contract", async function () {
    const Sign = await ethers.getContractFactory("Sign") as Sign__factory;
    const sign = await Sign.deploy() as Sign;
    await sign.deployed();
    expect(sign.address);
  });
});
