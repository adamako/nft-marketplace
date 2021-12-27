require("@nomiclabs/hardhat-waffle");
const projectId = "3de6c70add3f45d7b1e17727d4ce6968";
const fs = require("fs");
const keyData = fs
  .readFileSync("./p-key.txt", {
    encoding: "utf-8",
    flag: "r",
  })
  .toString()
  .trim();

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [keyData],
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${projectId}`,
      accounts: [keyData],
    },
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
