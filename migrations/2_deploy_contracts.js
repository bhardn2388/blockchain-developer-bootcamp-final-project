const Farmshop = artifacts.require("Farmshop");
const Security = artifacts.require("Security");

module.exports = function (deployer) {
  deployer.deploy(Farmshop);
  deployer.deploy(Security);
};