pragma solidity >=0.4.25 <0.7.0;

import "./ConvertLib.sol";

contract IoTDataMarketplace {
    address public owner;
    address[] public dataSellers;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
    }
}