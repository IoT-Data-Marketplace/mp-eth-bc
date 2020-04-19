const ConvertLib = artifacts.require("ConvertLib");
const IoTDataMarketplace = artifacts.require("IoTDataMarketplace");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, IoTDataMarketplace);
  deployer.deploy(IoTDataMarketplace);
};
