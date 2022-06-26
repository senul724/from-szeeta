const HDWalletProvider = require("@truffle/hdwallet-provider");
//
// const fs = require('fs');
const mnemonic = require("./secret.json").mnemonic;

module.exports = {
  networks: {

    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 7545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
    },

    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://speedy-nodes-nyc.moralis.io/8fe255314e2c9119e49be19d/eth/rinkeby`
        ),
      network_id: 4, // Ropsten's id
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },

    ropsten: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://speedy-nodes-nyc.moralis.io/8fe255314e2c9119e49be19d/eth/ropsten`
        ),
      network_id: 3, // Ropsten's id
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },

    maticTest: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://speedy-nodes-nyc.moralis.io/8fe255314e2c9119e49be19d/polygon/mumbai`
        ),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },

    bscTestnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://speedy-nodes-nyc.moralis.io/8fe255314e2c9119e49be19d/bsc/testnet`
        ),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.7", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    },
  },
  plugins: [
    "truffle-plugin-verify",
    "truffle-contract-size"
    ],

  api_keys: {
    //single api key can be used to work with all ethereum networks
    etherscan: "UEZHRID1CEHFGEQKNF51DVAQPSM636GDWC",
    polygonscan: "FSY4FAJNEDK1ZZYCU1CZ5A4A4Z1VDFWF77",
    bscscan:"N4QNF666AK71D962Z2NZEYS39YTKZC8NSS"
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows:
  // $ truffle migrate --reset --compile-all
  //
  // db: {
  // enabled: false,
  // host: "127.0.0.1",
  // adapter: {
  //   name: "sqlite",
  //   settings: {
  //     directory: ".db"
  //   }
  // }
  // }
};
