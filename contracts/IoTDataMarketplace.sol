pragma solidity ^0.4.17;
pragma experimental ABIEncoderV2;

/**
 * @title IoTDataMarketplace
 * @dev danijel.fon@gmail.com
 */
contract IoTDataMarketplace {
    address public ioTDataMarketplaceOwnerAddress;
    DataStreamProvider[] public dataStreamProviders;

    modifier restricted() {
        if (msg.sender == ioTDataMarketplaceOwnerAddress) _;
    }

    constructor() public {
        ioTDataMarketplaceOwnerAddress = msg.sender;
    }


    function registerDataStreamProvider(
        string memory _dataStreamProviderName
    ) public {
        DataStreamProvider newDataStreamProvider = new DataStreamProvider(
            address(this), msg.sender, _dataStreamProviderName);

        dataStreamProviders.push(newDataStreamProvider);
        emit DataStreamProviderRegistered(address(newDataStreamProvider));

    }

    event DataStreamProviderRegistered(address newAddress);


    function describeIoTDataMarketplace() public view returns (
        address,
        DataStreamProvider[] memory
    ) {
        return (
        ioTDataMarketplaceOwnerAddress,
        dataStreamProviders
        );
    }
}


/**
 *
 */
contract DataStreamProvider {
    address public iotDataMaketplaceContractAddress;
    address public dataStreamProviderOwnerAddress;
    string public name;

    IoTDevice[] public ioTDevices;

    constructor(
        address _iotDataMaketplaceContractAddress,
        address _dataStreamProviderOwnerAddress,
        string memory _name
    ) public {
        iotDataMaketplaceContractAddress = _iotDataMaketplaceContractAddress;
        dataStreamProviderOwnerAddress = _dataStreamProviderOwnerAddress;
        name = _name;
    }
}


/**
 * Represent an IoT Device, one IoT Device can have multiple sensors attached to it.
 * It should push the data directly to the IoTDataMarketplace
 */
contract IoTDevice {



    DataStreamProvider dataStreamProvider;
    IoTDevice[] public ioTDevices;



    constructor() public {

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
contract Sensor {

    using IoTDataMarketplaceLibrary for IoTDataMarketplaceLibrary.SensorType;
    using IoTDataMarketplaceLibrary for IoTDataMarketplaceLibrary.Geolocation;

    address ioTDeviceContractAddress;
    IoTDataMarketplaceLibrary.SensorType sensorType;
    IoTDataMarketplaceLibrary.Geolocation geolocation;
    string description;

    constructor(
        address _ioTDeviceContractAddress,
        IoTDataMarketplaceLibrary.SensorType _sensorType,
        IoTDataMarketplaceLibrary.Geolocation memory _geolocation,
        string memory _description
    ) public {
        ioTDeviceContractAddress = _ioTDeviceContractAddress;
        sensorType = _sensorType;
        geolocation = _geolocation;
        description = _description;
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
}