const Migrations = artifacts.require("Migrations");
const DiceGame = artifacts.require("DiceGame");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(DiceGame);
};
