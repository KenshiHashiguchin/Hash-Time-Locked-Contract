const ZennyToken = artifacts.require("ZennyToken");

module.exports = function (deployer) {
  deployer.deploy(ZennyToken);
};
