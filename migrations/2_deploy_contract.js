const Campaign = artifacts.require("Campaign");

module.exports = function(deployer) {
  deployer.deploy(Campaign,web3.utils.toWei('1', 'ether'));
};
