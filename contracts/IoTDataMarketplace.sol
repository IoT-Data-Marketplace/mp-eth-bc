pragma solidity ^0.4.17;
pragma experimental ABIEncoderV2;

/**
 * @title IoTDataMarketplace
 * @dev danijel.fon@gmail.com
 */
contract IoTDataMarketplace {
    address public ioTDataMarketplaceOwnerAddress;
    uint dataStreamEntityRegistrationPrice;
    uint sensorRegistrationPrice;
    uint8 dataStreamingCommissionRate;
    address[] public dataStreamEntities;
    mapping(address => address) dataStreamEntitiesOwnerToContractAddressMap;

    constructor(
        uint _dataStreamEntityRegistrationPrice,
        uint _sensorRegistrationPrice,
        uint8 _dataStreamingCommissionRate
    ) public {
        ioTDataMarketplaceOwnerAddress = msg.sender;
        dataStreamEntityRegistrationPrice = _dataStreamEntityRegistrationPrice;
        sensorRegistrationPrice = _sensorRegistrationPrice;
        dataStreamingCommissionRate = _dataStreamingCommissionRate;
    }


    function registerDataStreamEntity(
        string memory _dataStreamEntityName,
        string memory _dataStreamEntityURL,
        string memory _dataStreamEntityEmail
    ) public payable {
        require(msg.value >= dataStreamEntityRegistrationPrice, "You have to send enough money.");
        DataStreamEntity newDataStreamEntity = new DataStreamEntity(
            address(this),
            msg.sender,
            _dataStreamEntityName,
            _dataStreamEntityURL,
            _dataStreamEntityEmail
        );

        dataStreamEntities.push(address(newDataStreamEntity));
        dataStreamEntitiesOwnerToContractAddressMap[msg.sender] = address(newDataStreamEntity);
    }


    function describeIoTDataMarketplace() public view returns (
        address,
        address[],
        uint,
        uint,
        uint8
    ) {
        return (
        ioTDataMarketplaceOwnerAddress,
        dataStreamEntities,
        dataStreamEntityRegistrationPrice,
        sensorRegistrationPrice,
        dataStreamingCommissionRate
        );
    }

    function getDataStreamEntities() public view returns (address[]) {
        return (dataStreamEntities);
    }

    function getIoTDataMarketplaceOwnerAddress() public view returns (address) {
        return (ioTDataMarketplaceOwnerAddress);
    }

    function getDataStreamEntityRegistrationPrice() public view returns (uint) {
        return (dataStreamEntityRegistrationPrice);
    }

    function getSensorRegistrationPrice() public view returns (uint) {
        return (sensorRegistrationPrice);
    }

    function getDataStreamingCommissionRate() public view returns (uint8) {
        return (dataStreamingCommissionRate);
    }

    function getDataStreamEntityContractAddressForOwnerAddress(address dataStreamEntityOwnerAccountAddress) public view returns (
        address
    ) {
        return (
        dataStreamEntitiesOwnerToContractAddressMap[dataStreamEntityOwnerAccountAddress]
        );
    }

    function withdrawFunds() public payable {
        require(msg.sender == ioTDataMarketplaceOwnerAddress, "Sender not authorized");
        ioTDataMarketplaceOwnerAddress.transfer(address(this).balance);
    }

}


/*
 *
 */
contract DataStreamEntity {
    using IoTDataMPLibrary for IoTDataMPLibrary.SensoryType;

    address iotDataMarketplaceContractAddress;
    uint iotDataMarketplaceFunds;
    address dataStreamEntityOwnerAddress;
    string name;
    string url;
    string email;
    address[] sensors;
    // just for a quick lookup to check if this datastream entity is an owner of the sensor
    mapping(address => bool) sensorContractAddressToBoolMapping;

    // for a quick lookup to check if the datastream entity is subscribed for the sensor's data stream
    mapping(address => address) sensorContractAddressToDataStreamPurchaseContractAddressMap;
    address[] dataStreamPurchases;

    constructor(
        address _iotDataMarketplaceContractAddress,
        address _dataStreamEntityOwnerAddress,
        string memory _name,
        string memory _url,
        string memory _email
    ) public {
        iotDataMarketplaceContractAddress = _iotDataMarketplaceContractAddress;
        dataStreamEntityOwnerAddress = _dataStreamEntityOwnerAddress;
        name = _name;
        url = _url;
        email = _email;
    }

    function registerNewSensor(
        IoTDataMPLibrary.SensoryType _sensorType,
        string memory _latitude,
        string memory _longitude,
        uint _pricePerDataUnit
    ) public payable returns (address) {
        require(msg.sender == dataStreamEntityOwnerAddress, "Sender not authorized");
        IoTDataMarketplace ioTDataMarketplace = IoTDataMarketplace(iotDataMarketplaceContractAddress);
        require(msg.value >= ioTDataMarketplace.getSensorRegistrationPrice(), "You have to send enough money.");
        iotDataMarketplaceFunds += msg.value;
        Sensor sensor = new Sensor(
            address(this),
            _sensorType,
            _latitude,
            _longitude,
            _pricePerDataUnit
        );
        sensorContractAddressToBoolMapping[address(sensor)] = true;
        sensors.push(address(sensor));
        return address(sensor);
    }

    function buyDataStream(
        address _dataStreamEntityBayerContractAddress,
        address _sensorContractAddress,
        string _startTimestamp,
        uint128 _dataEntries
    ) public payable {
        Sensor sensor = Sensor(_sensorContractAddress);
        require(sensor.isSensorActive(), "Sensor not active");
        require(msg.value >= _dataEntries * sensor.getPricePerDataUnit(), "You have to send enough money.");
        require(sensorContractAddressToBoolMapping[_sensorContractAddress], "This datastream entity is not the owner of the given sensor");
        DataStreamPurchase dsp = new DataStreamPurchase(
            _dataStreamEntityBayerContractAddress,
            address(this),
            _startTimestamp,
            _dataEntries
        );
        sensorContractAddressToDataStreamPurchaseContractAddressMap[_sensorContractAddress] = address(dsp);
        dataStreamPurchases.push(address(dsp));
    }

    function getIotDataMarketplaceContractAddress() public view returns (address) {
        return (iotDataMarketplaceContractAddress);
    }

    function getDataStreamEntityOwnerAddress() public view returns (address) {
        return (dataStreamEntityOwnerAddress);
    }

    function getDataStreamPurchaseContractAddressForSensorContractAddressMap(address _sensorContractAddress) public view returns (address) {
        return (sensorContractAddressToDataStreamPurchaseContractAddressMap[_sensorContractAddress]);
    }

    function describeDataStreamEntity() public view returns (
        address,
        address,
        string,
        string,
        string,
        address[]
    ) {
        return (
        iotDataMarketplaceContractAddress,
        dataStreamEntityOwnerAddress,
        name,
        url,
        email,
        sensors
        );
    }


    function getSensors() public view returns (
        address[]
    ) {
        return (
        sensors
        );
    }

    function isAuthenticated() public view returns (bool) {
        return (dataStreamEntityOwnerAddress == msg.sender);
    }

    // the only way to distribute the funds. It was not possible to pay out the iotDataMarketplace at the sensor/datastream purchase describeDataStreamEntity
    // since it would require 2 blocks to mine the transaction
    function distributeFunds() public payable {
        require(msg.sender == dataStreamEntityOwnerAddress, "Sender not authorized");
        iotDataMarketplaceContractAddress.transfer(iotDataMarketplaceFunds);
        dataStreamEntityOwnerAddress.transfer(address(this).balance - iotDataMarketplaceFunds);
    }
}




/**
 *
 */
contract Sensor {
    using IoTDataMPLibrary for IoTDataMPLibrary.SensoryType;
    using IoTDataMPLibrary for IoTDataMPLibrary.SensorStatus;

    address dataStreamEntityContractAddress;
    IoTDataMPLibrary.SensoryType sensorType;
    string latitude;
    string longitude;
    IoTDataMPLibrary.SensorStatus sensorStatus;
    uint pricePerDataUnit;

    constructor(
        address _dataStreamEntityContractAddress,
        IoTDataMPLibrary.SensoryType _sensorType,
        string memory _latitude,
        string memory _longitude,
        uint _pricePerDataUnit
    ) public {
        dataStreamEntityContractAddress = _dataStreamEntityContractAddress;
        sensorType = _sensorType;
        latitude = _latitude;
        longitude = _longitude;
        pricePerDataUnit = _pricePerDataUnit;
        sensorStatus = IoTDataMPLibrary.SensorStatus.INACTIVE;
    }

    function setSensorStatus(IoTDataMPLibrary.SensorStatus _sensorStatus) public {
        DataStreamEntity dataStreamEntity = DataStreamEntity(dataStreamEntityContractAddress);
        IoTDataMarketplace ioTDataMarketplace = IoTDataMarketplace(dataStreamEntity.getIotDataMarketplaceContractAddress());
        require(msg.sender == ioTDataMarketplace.getIoTDataMarketplaceOwnerAddress(), "Sender not authorized");

        sensorStatus = _sensorStatus;
    }



    function describeSensor() public view returns (
        address,
        IoTDataMPLibrary.SensoryType,
        string memory,
        string memory,
        IoTDataMPLibrary.SensorStatus,
        uint
    ) {
        return (
        dataStreamEntityContractAddress,
        sensorType,
        latitude,
        longitude,
        sensorStatus,
        pricePerDataUnit
        );
    }

    function getPricePerDataUnit() public view returns (uint) {
        return (pricePerDataUnit);
    }

    function isSensorActive() public view returns (bool) {
        return (sensorStatus == IoTDataMPLibrary.SensorStatus.ACTIVE);
    }

    function getDataStreamEntityContractAddress() public view returns (address) {
        return (dataStreamEntityContractAddress);
    }

}


contract DataStreamPurchase {

    address dataStreamEntityBuyerContractAddress;
    address sensorContractAddress;
    string startTimestamp;  // e.g. "2020-05-10T13:10:00Z"
    uint128 dataEntries;

    constructor(
        address _dataStreamEntityBuyerContractAddress,
        address _sensorContractAddress,
        string _startTimestamp,
        uint128 _dataEntries
    ) public {
        dataStreamEntityBuyerContractAddress = _dataStreamEntityBuyerContractAddress;
        sensorContractAddress = _sensorContractAddress;
        startTimestamp = _startTimestamp;
        dataEntries = _dataEntries;
    }

    function getDataStreamEntityBuyerContractAddress() public view returns (address) {
        return (dataStreamEntityBuyerContractAddress);
    }

    function describeDataStreamPurchase() public view returns (
        address,
        address,
        string,
        uint128
    ) {
        return (
        dataStreamEntityBuyerContractAddress,
        sensorContractAddress,
        startTimestamp,
        dataEntries
        );
    }
}


/**
 *
 */
library IoTDataMPLibrary {

    enum SensoryType {
        TEMPERATURE,
        HUMIDITY,
        AIR_POLLUTION
    }

    enum SensorStatus {
        INACTIVE,
        ACTIVE,
        BLOCKED
    }

}