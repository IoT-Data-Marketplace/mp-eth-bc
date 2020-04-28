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
    address public iotDataMaketplaceContractAddress;
    address public dataStreamEntityOwnerAddress;
    string public name;
    string public url;
    string public email;

    address[] public ioTDevices;
    address[] public DataStreamPurchase;

    constructor(
        address _iotDataMaketplaceContractAddress,
        address _dataStreamEntityOwnerAddress,
        string memory _name,
        string memory _url,
        string memory _email
    ) public {
        iotDataMaketplaceContractAddress = _iotDataMaketplaceContractAddress;
        dataStreamEntityOwnerAddress = _dataStreamEntityOwnerAddress;
        name = _name;
        url = _url;
        email = _email;
    }
}


/**
 * Represent an IoT Device, one IoT Device can have multiple sensors attached to it.
 * It should push the data directly to the IoTDataMarketplace
 */
contract IoTDevice {
    using IoTDataMarketplaceLibrary for IoTDataMarketplaceLibrary.Geolocation;

    address public dataStreamEntityContractAddress;
    address[] public sensors;
    IoTDataMarketplaceLibrary.Geolocation geolocation;


    constructor(
        address _dataStreamEntityContractAddress,
        IoTDataMarketplaceLibrary.Geolocation memory _geolocation
    ) public {
        dataStreamEntityContractAddress = _dataStreamEntityContractAddress;
        geolocation = _geolocation;
    }


    function describeIoTDevice() public view returns (
        address,
        address[] memory
    ) {
        return (
        dataStreamEntityContractAddress,
        sensors
        );
    }

}


/**
 *
 */
contract Sensor {

    using IoTDataMarketplaceLibrary for IoTDataMarketplaceLibrary.SensorType;

    address ioTDeviceContractAddress;
    IoTDataMarketplaceLibrary.SensorType sensorType;
    string description;

    constructor(
        address _ioTDeviceContractAddress,
        IoTDataMarketplaceLibrary.SensorType _sensorType,
        string memory _description
    ) public {
        ioTDeviceContractAddress = _ioTDeviceContractAddress;
        sensorType = _sensorType;
        description = _description;
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