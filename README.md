# COMPUTER PROJECT DESIGN
###### tags: `GETH`

* [Source Code](https://novayo.github.io/NCKU_COMPUTER_PROJECT_DESIGN/)
* [Hackmd](https://hackmd.io/iqub9lj-S0ixUDCbdIl4mQ)
* [System Documentation](https://drive.google.com/file/d/1-cgij5cn3qu3t_iRPwIMH-lFw4dS4A7N/view?usp=sharing)
---

## Project Folder Structure
>   - contracts
>     - CrowdFunding.sol
>     - HelloWorld.sol
>     - MatchMaker.sol
>   - utils
>     - gensis.json
>     - mineWhenNeeded.js
>     - addDefaultAccount_in_Gensis.js
>   - call_CrowdFunding.js
>   - call_HelloWorld.js
>   - call_MatchMaker.js
>   - deploy_contract.js
>   - package.json
>   - geth_firstRun .sh
>   - geth_start .sh
    
## Environment
* [Node js](https://nodejs.org/en/download/)
* Geth： [Ubuntu](https://github.com/ethereum/go-ethereum/wiki/Installing-Geth#install-on-ubuntu-via-ppas) ， [Mac](https://github.com/ethereum/go-ethereum/wiki/Installation-Instructions-for-Mac)

        # On Ubuntu
        sudo apt-get update
        sudo apt-get install ethereum
        
        # On Mac
        brew tap ethereum/ethereum
        brew install ethereum

## Building
1. 初始化區塊鏈環境

        ./geth_firstRun.sh
2. 安裝相關套件

        sudo npm install
    
## Usage
1. 執行區塊鏈server

        ./geth_start.sh
2. 開啟另一個terminal並部署合約上去

        node deploy_contract.js
3. 複製顯示的地址到**call_HelloWorld.js**的第9行 
4. 呼叫合約

        node call_HelloWorld.js
        
## Handle Error Msg
* **ERROR: Invalid Address**
    > [Solution](https://ethereum.stackexchange.com/questions/2086/cannot-perform-write-functions-in-smart-contract-invalid-address)
* **Invalid asm.js: Invalid member of stdlib** 
    > Solution: Add "--no-warnings" while using node
    >   `node --no-warnings deploy_contract.js`
* **Error: invalid argument 0: json: cannot unmarshal hex string of odd length into Go value of type hexutil.Bytes**
    > Solution: 合約有寫錯
* **BigNumber Error: new BigNumber() not a base 16 number**
    > Solution: 合約的Construct寫錯

## Reference
1. https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
2. https://stackoverflow.com/questions/54499116/how-do-you-compare-strings-in-solidity
3. https://ethereum.stackexchange.com/questions/63515/how-to-access-string-arguments-from-calldata-in-external-functions-0-5-x
4. https://ethereum.stackexchange.com/questions/45972/ive-got-an-error-while-compiling-use-constructor-instead
