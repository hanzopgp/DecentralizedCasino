const Migrations = artifacts.require("Migrations");
const Casino = artifacts.require("Casino");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Casino);
};
