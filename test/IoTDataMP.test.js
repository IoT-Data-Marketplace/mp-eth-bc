const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledMarketplace = require('../build/IoTDataMarketplace.json');
const compiledDataStreamEntity = require('../build/DataStreamEntity.json');
const compiledSensor = require('../build/Sensor.json');


let accounts;
let marketplace;
let dataStreamEntityAddress;
let dataStreamEntity;

let sensor;
let sensorContractAddress;

let iotDataMarketplaceOwnerAccountAddress;
let dataStreamEntityOwnerAccountAddress;
let someRandomAccountAddress;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    iotDataMarketplaceOwnerAccountAddress = accounts[0];
    dataStreamEntityOwnerAccountAddress = accounts[1];
    someRandomAccountAddress = accounts[7];
    marketplace = await new web3.eth.Contract(JSON.parse(compiledMarketplace.interface))
        .deploy({
            data: compiledMarketplace.bytecode,
            arguments: [500000, 500000, 20]
        })
        .send({
            from: iotDataMarketplaceOwnerAccountAddress,
            gas: '3000000'
        });

    await marketplace.methods.registerDataStreamEntity('Test', 'test', 'test')
        .send({
            from: dataStreamEntityOwnerAccountAddress,
            gas: '3000000',
            value: '500000'
        });

    [dataStreamEntityAddress] = await marketplace.methods.getDataStreamEntities().call();

    dataStreamEntity = await new web3.eth.Contract(
        JSON.parse(compiledDataStreamEntity.interface),
        dataStreamEntityAddress
    )

    await dataStreamEntity.methods.registerNewSensor(1, 'long', 'lat', 1000).send({
        from: dataStreamEntityOwnerAccountAddress,
        gas: '3000000',
        value: '500000'
    });

    [sensorContractAddress] = await dataStreamEntity.methods.getSensors().call();

    sensor = await new web3.eth.Contract(
        JSON.parse(compiledSensor.interface),
        sensorContractAddress
    )

});

describe('Marketplace', () => {
    it('deploys a marketplace and a dataStreamEntity', () => {
        assert.ok(marketplace.options.address);
        assert.ok(dataStreamEntity.options.address);
    });


    it('marks caller as the iot data marketplace owner', async () => {
        const ioTDataMarketplaceOwnerAddress = await marketplace.methods.getIoTDataMarketplaceOwnerAddress().call();
        assert.equal(accounts[0], ioTDataMarketplaceOwnerAddress);
    });


    it('allow the data stream entity to register new sensor when it sends enough money', async () => {
        await dataStreamEntity.methods.registerNewSensor(1, 'long', 'lat', 1000).send({
            from: dataStreamEntityOwnerAccountAddress,
            gas: '3000000',
            value: '500000'
        });
        assert(true);
    });

    it('fail on register new sensor when it doesnt send enough money', async () => {
        await assert.rejects(async () => {
            await dataStreamEntity.methods.registerNewSensor(1, 'long', 'lat', 1000).send({
                from: dataStreamEntityOwnerAccountAddress,
                gas: '3000000',
                value: '500'
            });
        }, {
            message: /You have to send enough money/
        });
    });

    it('fails on register new sensor when not authorized', async () => {
        await assert.rejects(async () => {
            await dataStreamEntity.methods.registerNewSensor(1, 'long', 'lat', 1000).send({
                from: someRandomAccountAddress,
                gas: '3000000',
                value: '500000'
            });
        }, {
            message: /Sender not authorized/
        });
    });


    it('can buy data stream', async () => {
        await dataStreamEntity.methods.buyDataStream(
            someRandomAccountAddress,
            sensorContractAddress,
            '2020-05-10T13:10:00Z',
            1000000
        ).send({
            from: someRandomAccountAddress,
            gas: '3000000',
            value: 1000 * 1000000
        });
        assert(true);
    });

    it('iot data marketplace can update sensor status', async () => {
        await sensor.methods.setSensorStatus(2).send({
            from: iotDataMarketplaceOwnerAccountAddress,
            gas: '3000000',
        });
        assert(true);
    });

    it('fails on update sensor status when dataStreamEntityOwnerAccountAddress sender not authorized', async () => {
        await assert.rejects(async () => {
            await sensor.methods.setSensorStatus(2).send({
                from: dataStreamEntityOwnerAccountAddress,
                gas: '3000000',
            });
        }, {
            message: /Sender not authorized/
        });
    });

    it('fails on update sensor status when someRandomAccountAddress sender not authorized', async () => {
        await assert.rejects(async () => {
            await sensor.methods.setSensorStatus(2).send({
                from: someRandomAccountAddress,
                gas: '3000000',
            });
        }, {
            message: /Sender not authorized/
        });
    });

});