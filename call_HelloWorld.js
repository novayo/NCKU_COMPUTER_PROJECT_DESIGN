const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');
const demo = 0;
const ethereumUrl = 'http://localhost:8545';


/*********************************************************/
const addr = '0x06b8657a1e8acec703e2789c50356f2faef64ea5'; // Copy the contract address here
/*********************************************************/


let web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider(ethereumUrl));
const address = web3.eth.accounts[0]; // user
if(!web3.isConnected()){
    throw new Error('unable to connect to ethereum node at ' + ethereumUrl);
}else{
    if (demo == 1)console.log('connected to ehterum node at ' + ethereumUrl);
    let coinbase = web3.eth.coinbase;
    if (demo == 1)console.log('coinbase:' + coinbase);
    let balance = web3.eth.getBalance(coinbase);
    if (demo == 1)console.log('balance:' + web3.fromWei(balance, 'ether') + " ETH");
    let accounts = web3.eth.accounts;
    if (demo == 1)console.log(accounts);
    
    if (web3.personal.unlockAccount(address, '1')) {
        if (demo == 1)console.log(`${address} is unlocaked`);
    }else{
        if (demo == 1)console.log(`unlock failed, ${address}`);
    }
}


let source = fs.readFileSync("./contracts/HelloWorld.sol", 'utf8');

if (demo == 1)console.log('compiling contract...');
let compiledContract = solc.compile(source);
if (demo == 1)console.log('done');

for (let contractName in compiledContract.contracts) {
    var bytecode = compiledContract.contracts[contractName].bytecode;
    var abi = JSON.parse(compiledContract.contracts[contractName].interface);
}


// https://ethereum.stackexchange.com/questions/55222/uncaught-typeerror-this-eth-sendtransaction-is-not-a-function?rq=1
// https://blog.csdn.net/hdyes/article/details/80818183
var MyContract = web3.eth.contract(abi).at(addr);
var text = MyContract.say({from: address, gas: 50000,});
console.log(text);
var t = MyContract.setMessage("施崇祐", {from: address, gas: 50000,});
var text2 = MyContract.getMessage({from: address, gas: 50000,});
console.log(text2);
