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

    function getDataStreamEntityContractAddressForOwnerAddress(address dataStreamEntityOwnerAccountAddress) public view returns (
        address
    ) {
        return (
        dataStreamEntitiesOwnerToContractAddressMap[dataStreamEntityOwnerAccountAddress]
        );
    }

}


/**
 *
 */
contract DataStreamEntity {
    address public iotDataMarketplaceContractAddress;
    address public dataStreamEntityOwnerAddress;
    string public name;
    string public url;
    string public email;
    Sensor[] public sensors;

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

    function describeDataStreamEntity() public view returns (
        address,
        address,
        string,
        string,
        string,
        Sensor[]
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

    function isAuthenticated() public view returns (bool) {
        return (dataStreamEntityOwnerAddress == msg.sender);
    }
}




/**
 *
 */
contract Sensor {

    using IoTDataMarketplaceLibrary for IoTDataMarketplaceLibrary.SensorType;
    using IoTDataMarketplaceLibrary for IoTDataMarketplaceLibrary.Geolocation;

    address dataStreamEntityContractAddress;
    IoTDataMarketplaceLibrary.SensorType sensorType;
    IoTDataMarketplaceLibrary.Geolocation geolocation;
    string description;

    constructor(
        address _dataStreamEntityContractAddress,
        IoTDataMarketplaceLibrary.SensorType _sensorType,
        IoTDataMarketplaceLibrary.Geolocation memory _geolocation,
        string memory _description
    ) public {
        dataStreamEntityContractAddress = _dataStreamEntityContractAddress;
        sensorType = _sensorType;
        description = _description;
        geolocation = _geolocation;
    }


}


/**
 *
 */
contract DataStreamPurchase {

    using IoTDataMarketplaceLibrary for IoTDataMarketplaceLibrary.DateTime;

    Sensor sensor;

    IoTDataMarketplaceLibrary.DateTime fromData;
    IoTDataMarketplaceLibrary.DateTime toDate;

    constructor() public {

    }
}




/**
 *
 */
library IoTDataMarketplaceLibrary {

    enum SensoryType {
        TEMPERATURE,
        HUMIDITY,
        AIR_POLUTION
    }

    struct Geolocation {
        string longitude;
        string latitude;
    }

    struct DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
    }

    enum SensorType {
        TEMPERATURE,
        HUMIDITY
    }

    struct SensorDetails {
        SensorType sensorType;
        string description;
    }
}