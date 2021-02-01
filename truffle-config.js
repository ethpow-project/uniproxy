const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  compilers: {
    solc: {
        version: '0.6.12',
        settings: { // See the solidity docs for advice about optimization and evmVersion
            optimizer: {
                enabled: true,
                runs: 100,
            },
        },
    },
  },
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
    },
    mainnet: infuraProvider("mainnet", 1),
    ropsten: infuraProvider("ropsten", 3),
    kovan: infuraProvider("kovan", 42),
  },
  mocha: {
    timeout: 10000,
    reporter: "Spec",
  },
  plugins: [],
};

function infuraProvider(network, networkId) {
  return {
    provider() {
      const { MNEMONIC, INFURA_API_KEY } = process.env;
      if (!MNEMONIC || !INFURA_API_KEY) {
        console.error(
          "Environment variables MNEMONIC and INFURA_API_KEY are required"
        );
        process.exit(1);
      }
      return new HDWalletProvider(
        MNEMONIC,
        `https://${network}.infura.io/v3/${INFURA_API_KEY}`
      );
    },
    network_id: networkId,
  };
}
