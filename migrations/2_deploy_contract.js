const Contract = artifacts.require("Contract");

module.exports = async (deployer, _network, accounts) => {
  deployer.deploy(Contract, {
    functionCalled: false,
    admin: "tz1TP5Are685mU29aAmTE6eBwRENwp1qhUdw",
    number: "0",
  });
};
