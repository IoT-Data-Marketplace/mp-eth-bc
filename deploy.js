const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledDataMarketplace = require('./build/IoTDataMarketplace')
require('dotenv').config();

const provider = new HDWalletProvider(
    process.env.ETHEREUM_ACCOUNT_MNEMONIC_SEED_PHRASES,
    process.env.ETHEREUM_INFURA_RINKEBY_ENDPOINT
);


const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log('Attempting to deploy the Data Marketplace contract from account: ', accounts[0]);
    // https://ethereum.stackexchange.com/questions/47482/error-the-contract-code-couldnt-be-stored-please-check-your-gas-limit
    const result = await new web3
        .eth
        .Contract(JSON.parse(compiledDataMarketplace.interface))
        .deploy({
            data: '0x' + compiledDataMarketplace.bytecode,
            arguments: [500000, 500000, 20]
        })
        .send({gas: 3000000, from: accounts[0]});

    console.log('Data Marketplace Contract deployed to: ', result.options.address);
};

deploy().catch(error => {
    console.log(error)
});