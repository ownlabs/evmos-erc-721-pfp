const EvmosNFT = artifacts.require("./EvmosNFT.sol");
const fs = require('fs')

module.exports = async(deployer, network) => {
    // OpenSea proxy registry addresses for rinkeby and mainnet.
    let proxyRegistryAddress = "0x0000000000000000000000000000000000000000";

    const contractName = process.env.NAME;
    const contractTicker = process.env.TICKER;
    const contractDescription = process.env.DESCRIPTION;

    await deployer.deploy(EvmosNFT, proxyRegistryAddress, contractName, contractTicker, contractDescription);
    const contract = await EvmosNFT.deployed();

    let configs = JSON.parse(fs.readFileSync('./configs/' + network + '.json').toString())
    console.log('Saving address in config file..')
    configs.contract_address = contract.address
    fs.writeFileSync('./configs/' + network + '.json', JSON.stringify(configs, null, 4))
    console.log('--')

};