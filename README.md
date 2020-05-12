## Java Setup

https://github.com/web3j/web3j

```solcjs ./contracts/IoTDataMarketplace.sol --bin --abi --optimize -o java-output/```

```web3j solidity generate -b ./java-output/__contracts_IoTDataMarketplace_sol_Sensor.bin -a ./java-output/__contracts_IoTDataMarketplace_sol_Sensor.abi -o ./java-output/ -p com.iotdatamp.mpbcclient```