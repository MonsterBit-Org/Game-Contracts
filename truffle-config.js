require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");
const web3 = new Web3();

module.exports = {
  networks: {
    development: {
      host: "localhost",
      network_id: "*",
      port: 8545,
    },
    coverage: {
      host: "localhost",
      network_id: "*",
      port: 8555,         // <-- If you change this, also set the port option in .solcover.js.
      gas: 0xfffffffffff, // <-- Use this high gas value
      gasPrice: 0x01      // <-- Use this low gas price
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(process.env.DEPLOYER_PK, `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`);
      },
      network_id: 4,
      gasPrice: web3.utils.toWei("10", "gwei"),
      from: process.env.DEPLOYER_ADDRESS.toLowerCase(),
    }
  },
  compilers: {
    solc: {
      version: "0.4.26",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  },
  plugins: [
    "truffle-plugin-verify",
    "solidity-coverage"
  ],
  api_keys: { // used by 'truffle-plugin-verify'
    etherscan: process.env.ETHERSCAN_API_KEY
  }
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
};