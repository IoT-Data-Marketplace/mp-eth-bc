pragma solidity ^0.4.17;
pragma experimental ABIEncoderV2;

/**
 * @title IoTDataMarketplace
 * @dev danijel.fon@gmail.com
 */
contract IoTDataMarketplace {
    address public ioTDataMarketplaceOwnerAddress;
    DataStreamEntity[] public dataStreamEntities;
    mapping(address => address) dataStreamEntitiesOwnerToContractAddressMap;
    uint8 commisionRate; // todo

    modifier restricted() {
        if (msg.sender == ioTDataMarketplaceOwnerAddress) _;
    }

    constructor() public {
        ioTDataMarketplaceOwnerAddress = msg.sender;
    }


    function registerDataStreamEntity(
        string memory _dataStreamEntityName,
        string memory _dataStreamEntityURL,
        string memory _dataStreamEntityEmail
    ) public {
        DataStreamEntity newDataStreamEntity = new DataStreamEntity(
            address(this),
            msg.sender,
            _dataStreamEntityName,
            _dataStreamEntityURL,
            _dataStreamEntityEmail
        );

        dataStreamEntities.push(newDataStreamEntity);
        dataStreamEntitiesOwnerToContractAddressMap[msg.sender] = address(newDataStreamEntity);
        emit DataStreamEntityRegistered(address(newDataStreamEntity));

    }

    event DataStreamEntityRegistered(address newAddress);


    function describeIoTDataMarketplace() public view returns (
        address,
        DataStreamEntity[] memory
    ) {
        return (
        ioTDataMarketplaceOwnerAddress,
        dataStreamEntities
        );
    }

    function getIoTDataMarketplaceOwnerAddress() public view returns (address) {
        return (ioTDataMarketplaceOwnerAddress);
    }

    function getDataStreamEntityContractAddressForOwnerAddress(address dataStreamEntityOwnerAccountAddress) public view returns (
        address
    ) {
        return (
        dataStreamEntitiesOwnerToContractAddressMap[dataStreamEntityOwnerAccountAddress]
        );
    }

}


/*
 *
 */
contract DataStreamEntity {
    using IoTDataMPLibrary for IoTDataMPLibrary.SensoryType;

    address public iotDataMarketplaceContractAddress;
    address public dataStreamEntityOwnerAddress;
    string public name;
    string public url;
    string public email;
    address[] public sensors;


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
        string memory _longitude
    ) public returns(address) {
        require(msg.sender == dataStreamEntityOwnerAddress);

        Sensor sensor = new Sensor(
            address(this),
            _sensorType,
            _latitude,
            _longitude
        );
        sensors.push(address(sensor));
        return address(sensor);
    }

    function geIotDataMarketplaceContractAddress() public view returns (address) {
        return (iotDataMarketplaceContractAddress);
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
    uint pricePerDataUnit; // todo put this in the constructor

    constructor(
        address _dataStreamEntityContractAddress,
        IoTDataMPLibrary.SensoryType _sensorType,
        string memory _latitude,
        string memory _longitude
    ) public {
        dataStreamEntityContractAddress = _dataStreamEntityContractAddress;
        sensorType = _sensorType;
        latitude = _latitude;
        longitude = _longitude;
        sensorStatus = IoTDataMPLibrary.SensorStatus.INACTIVE;
    }

    function setSensorStatus(IoTDataMPLibrary.SensorStatus _sensorStatus) public {
        DataStreamEntity dataStreamEntity = DataStreamEntity(dataStreamEntityContractAddress);
        IoTDataMarketplace ioTDataMarketplace = IoTDataMarketplace(dataStreamEntity.geIotDataMarketplaceContractAddress());
        require(msg.sender == ioTDataMarketplace.getIoTDataMarketplaceOwnerAddress(), "Sender not authorized"); // ensure that only the iotDataMarketplace can change the sensorStatus

        sensorStatus = _sensorStatus;
    }

    function buyDataStream() public payable {

    }

    function describeSensor() public view returns (
        address,
        IoTDataMPLibrary.SensoryType,
        string memory,
        string memory,
        IoTDataMPLibrary.SensorStatus
    ) {
        return (
        dataStreamEntityContractAddress,
        sensorType,
        latitude,
        longitude,
        sensorStatus
        );
    }

}


contract DataStreamPurchase {
    using IoTDataMPLibrary for IoTDataMPLibrary.SensoryType;

    address dataStreamEntityBuyer;
    address sensorContractAddress;


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

    struct DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
    }

}