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
        string memory _dataStreamEntityEmail,
        string memory _rsaPublicKey
    ) public payable {
        require(msg.value >= dataStreamEntityRegistrationPrice, "You have to send enough money.");
        DataStreamEntity newDataStreamEntity = new DataStreamEntity(
            address(this),
            msg.sender,
            _dataStreamEntityName,
            _dataStreamEntityURL,
            _dataStreamEntityEmail,
            _rsaPublicKey
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
    string rsaPublicKey;
    address[] sensors;
    // just for a quick lookup to check if this datastream entity is an owner of the sensor
    mapping(address => bool) sensorContractAddressToBoolMapping;

    constructor(
        address _iotDataMarketplaceContractAddress,
        address _dataStreamEntityOwnerAddress,
        string memory _name,
        string memory _url,
        string memory _email,
        string memory _rsaPublicKey
    ) public {
        iotDataMarketplaceContractAddress = _iotDataMarketplaceContractAddress;
        dataStreamEntityOwnerAddress = _dataStreamEntityOwnerAddress;
        name = _name;
        url = _url;
        email = _email;
        rsaPublicKey = _rsaPublicKey;
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

    function getIotDataMarketplaceContractAddress() public view returns (address) {
        return (iotDataMarketplaceContractAddress);
    }

    function getDataStreamEntityOwnerAddress() public view returns (address) {
        return (dataStreamEntityOwnerAddress);
    }

    function describeDataStreamEntity() public view returns (
        address,
        address,
        string,
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
        rsaPublicKey,
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
    address[] dataStreamSubscriptions;
    // for a quick lookup to check if the dsp is subscribed to the data stream
    mapping(address => address) dataStreamEntityContractAddressToDataStreamSubscriptionContractAddressMap;

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


    function buyDataStream(
        address _dataStreamEntityBayerContractAddress,
        string _startTimestamp,
        uint128 _dataEntries
    ) public payable {
        require(isSensorActive(), "Sensor not active");
        require(msg.value >= _dataEntries * pricePerDataUnit, "You have to send enough money.");
        DataStreamSubscription dsp = new DataStreamSubscription(
            _dataStreamEntityBayerContractAddress,
            address(this),
            _startTimestamp,
            _dataEntries
        );
        dataStreamEntityContractAddressToDataStreamSubscriptionContractAddressMap[_dataStreamEntityBayerContractAddress] = address(dsp);
        dataStreamSubscriptions.push(address(dsp));
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


    function getDataStreamSubscriptionContractAddressForDSE(address _dataStreamEntityContractAddress) public view returns (address) {
        return dataStreamEntityContractAddressToDataStreamSubscriptionContractAddressMap[_dataStreamEntityContractAddress];
    }

}


contract DataStreamSubscription {

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

    function describeDataStreamSubscription() public view returns (
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