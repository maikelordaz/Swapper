require ("dotenv").config();
require ("@nomiclabs/hardhat-waffle");
require ("@nomiclabs/hardhat-etherscan");
require ("hardhat-gas-reporter");
require ("solidity-coverage");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-web3");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.7.0",
      },
      {
        version: "0.7.6",
      },
      {
        version: "0.8.4",
        settings: {},
      },
    ],
  },

  defaultNetwork: "hardhat",
   networks: {
     hardhat: {
       forking: {
         url: process.env.ALCHEMY_MAINNET_RPC_URL,
         blockNumber: 14381000
       }
     }
    }
};
