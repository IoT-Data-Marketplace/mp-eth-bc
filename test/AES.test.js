const assert = require('assert');
var aesjs = require('aes-js');

describe('AES_Encryption', () => {
    it('should do sth', function () {
        const plainTextToEncrypt = '66.0C';
        const keyPlainText = '9F86D081884C7D659A2FEAA0C55AD015';
        const key_array = [...Buffer.from(keyPlainText)]
        const key = new Uint8Array(key_array);
        // console.log('key: ', key_array);
        // console.log('key: ', key);

        const text = aesjs.padding.pkcs7.pad([...Buffer.from(plainTextToEncrypt)]);
        console.log('text: ', text);

        const aesEcb = new aesjs.ModeOfOperation.ecb(key);
        var encryptedBytes = aesEcb.encrypt(text);

        const encryptedHex = aesjs.utils.hex.fromBytes(encryptedBytes);
        console.log(encryptedHex);

        var encryptedBytes = aesjs.utils.hex.toBytes(encryptedHex);

        const decryptedBytes = aesEcb.decrypt(encryptedBytes);

        const decryptedText = aesjs.utils.utf8.fromBytes(decryptedBytes);

        console.log('plainTextToEncrypt: ', plainTextToEncrypt);
        console.log('decryptedText: ', decryptedText);

        console.log('equal: ', plainTextToEncrypt == decryptedText.replace('C', ''));

        assert.equal(plainTextToEncrypt, decryptedText, "They are not equal")
    });

});