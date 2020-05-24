const assert = require('assert');
var sha256 = require('js-sha256');

describe('SHA_Hashing', () => {
    it('should Hash', function () {
        console.log(
            sha256.sha256('9F86D081884C7D659A2FEAA0C55AD015')
        )
    });
});