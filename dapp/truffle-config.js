var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "sheriff estate machine step swarm deputy enact raven spare salad theme meat";
module.exports = {
 networks: {
  development: {
   host: "127.0.0.1",
   port: 8545,
   network_id: "*"
  },
  test: {
   host: "127.0.0.1",
   port: 8545,
   network_id: "*"
  },
  rinkeby: {
      provider: function() { 
       return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/ed8b6be686064e18a11a7bfb424f2829");
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 100,
  }
 }
};
