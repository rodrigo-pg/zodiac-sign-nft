import '@nomiclabs/hardhat-ethers';
import "@nomiclabs/hardhat-waffle";
import '@typechain/hardhat';
import { config as dotenvConfig } from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import { NetworkUserConfig } from 'hardhat/types';
import { resolve } from "path";
import "./tasks/accounts";

dotenvConfig({ path: resolve(__dirname, "./.env") });

function getChainConfig(chainName: string): NetworkUserConfig {
  if(chainName === "localtest"){
    return { 
      url:process.env.LOCAL_TEST_URL,
      accounts:[process.env.LOCAL_TEST_ACCOUNT as string]
    }
  } else {
    return { 
      url:`https://${chainName}.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts:[process.env.chainName?.toUpperCase() as string]
    }
  }
}

const config: HardhatUserConfig = {
  solidity:{
    version: '0.8.7'
  },
  networks:{
    rinkeby: getChainConfig("rinkeby"),
    localtest: getChainConfig("localtest"),
  }
}

 export default config;