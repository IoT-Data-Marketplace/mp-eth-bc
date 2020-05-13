const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledMarketplace = require('../build/IoTDataMarketplace.json');


let accounts;
let marketplace;
let marketplaceAddress;

beforeEach(async () => {
   accounts = await web3.eth.getAccounts();
   marketplace = await new web3.eth.Contract(JSON.parse(compiledMarketplace.interface))
       .deploy({
           data: compiledMarketplace.bytecode,
           arguments: [500000, 500000, 20]
       })
       .send({
           from: accounts[0],
           gas: '3000000'
       });


   await marketplace.methods.registerDataStreamEntity('Test', 'test', 'test')
       .send({
           from: accounts[0],
           gas: '3000000',
           value: 500000
       });

});

describe('Marketplace', () => {
    it('deploys a marketplace and a campaign', () => {
        assert.ok(true);
    });
});