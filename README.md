# COMPUTER PROJECT DESIGN
###### tags: `GETH`

* [Source Code](https://github.com/novayo/NCKU_COMPUTER_PROJECT_DESIGN)
* [Hackmd](https://hackmd.io/iqub9lj-S0ixUDCbdIl4mQ)
---

## Project Folder Structure
>   - contracts
>     - CrowdFunding.sol
>     - HelloWorld.sol
>     - MatchMaker.sol
>   - call_CrowdFunding.js
>   - call_HelloWorld.js
>   - call_MatchMaker.js
>   - deploy_contract.js
>   - gensis.json
>   - package.json
>   - firstRunGeth .sh
>   - geth .sh
    
## Environment
* Node js
* Geth

## Building
1. 建立一個db資料夾

        mkdir db
        
2. 初始化區塊鏈環境

        geth --datadir "./db" init gensis.json
3. 安裝相關套件

        sudo npm install
4. 先建立一個default帳號

        ./firstRunGeth.sh
        
        /*** In geth console ***/
        personal.newAccount("1")
        exit
        
## Usage
1. 執行區塊鏈server

        ./geth.sh
2. 開啟另一個terminal並部署合約上去

        node deploy_contract.js

3. 複製顯示的地址到**call_HelloWorld.js**的第8行 
4. 呼叫合約

        node call_HelloWorld.js
        
## Handle Error Msg
* **ERROR: Invalid Address**
    * [Solution](https://ethereum.stackexchange.com/questions/2086/cannot-perform-write-functions-in-smart-contract-invalid-address)
* **Invalid asm.js: Invalid member of stdlib** 
    * Solution: Add "--no-warnings" while using node
        `node --no-warnings deploy_contract.js`
* **Error: invalid argument 0: json: cannot unmarshal hex string of odd length into Go value of type hexutil.Bytes**
    * Solution: 合約有寫錯
* **BigNumber Error: new BigNumber() not a base 16 number**
    * Solution

## Reference
1. https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
2. https://stackoverflow.com/questions/54499116/how-do-you-compare-strings-in-solidity
3. https://ethereum.stackexchange.com/questions/63515/how-to-access-string-arguments-from-calldata-in-external-functions-0-5-x
4. https://ethereum.stackexchange.com/questions/45972/ive-got-an-error-while-compiling-use-constructor-instead