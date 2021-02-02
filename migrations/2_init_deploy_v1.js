const ExchangeBroker = artifacts.require("ExchangeBroker");

module.exports = async (deployer) => {
  const _WETH_ = "0xd0A1E359811322d97991E03f863a0C30C2cF029C";
  const _UNI_ = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  await deployer.deploy(ExchangeBroker, _WETH_, _UNI_);
};
