const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const foodChainPath = path.resolve(__dirname, 'contracts', 'IoTDataMarketplace.sol');

const source = fs.readFileSync(foodChainPath, 'utf8');
let output = null;


(function () {
    try {
        output = solc.compile(source, 1).contracts;
    } catch (e) {
        console.error("Error while compiling: ", e);
    }
})();


fs.ensureDirSync(buildPath);

console.log('Output: ', output);

for (let contract in output) {
    fs.outputJsonSync(
        path.resolve(buildPath, `${contract.replace(':', '')}.json`),
        output[contract]
    );
}

// to compile: node ./src/ethereum/compile.js