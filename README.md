# Geth

建立geth資料夾
在geth資料夾內
1. 建立gensis.json
2. 建立db資料夾
3. 執行

            geth --datadir "./db" init gensis.json
5. sudo npm init
6. sudo npm install --save ganache-cli
7. sudo npm install --save web3@0.20.0
8. sudo npm install --save solc@0.4.25

> 先在區塊鏈建立一個帳戶
> personal.newAccount("1")
> eth.accounts
> exit

可以跑了(還沒做可以指定contract(預設是helloworld))
1. node deploy_contract.js
2. 把deploy 上去的address複製到call_HelloWorld的第44行
3. node call_HelloWorld.js(最後會有一個warning msg(不影響程式))


日後目標：
1. 回傳contract的addr到mySQL

[ERROR: Invalid Address](https://ethereum.stackexchange.com/questions/2086/cannot-perform-write-functions-in-smart-contract-invalid-address)
Invalid asm.js: Invalid member of stdlib: --no-warnings
Error: invalid argument 0: json: cannot unmarshal hex string of odd length into Go value of type hexutil.Bytes: 合約有寫錯
Reference:
1. https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
2. https://stackoverflow.com/questions/54499116/how-do-you-compare-strings-in-solidity
3. https://ethereum.stackexchange.com/questions/63515/how-to-access-string-arguments-from-calldata-in-external-functions-0-5-x
4. https://ethereum.stackexchange.com/questions/45972/ive-got-an-error-while-compiling-use-constructor-instead