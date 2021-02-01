const ExchangeBroker = artifacts.require("ExchangeBroker");

module.exports = async (deployer) => {
  await deployer.deploy(ExchangeBroker);
};
