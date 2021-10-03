const HashTimeLockedContract = artifacts.require("HashTimeLockedContract");

module.exports = function (deployer) {
  deployer.deploy(HashTimeLockedContract);
};
