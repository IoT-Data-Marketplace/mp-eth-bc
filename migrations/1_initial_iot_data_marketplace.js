const IoTDataMarketplace = artifacts.require("IoTDataMarketplace");

module.exports = function(deployer) {
  deployer.deploy(IoTDataMarketplace);
};
