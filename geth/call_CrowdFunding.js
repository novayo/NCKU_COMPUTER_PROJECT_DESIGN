const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');

const ethereumUri = 'http://localhost:8545'; 
 

let web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider(ethereumUri));
const address0 = web3.eth.accounts[0]; // user
const address1 = web3.eth.accounts[1]; // user
const address2 = web3.eth.accounts[2]; // user
const address3 = web3.eth.accounts[3]; // user
if(!web3.isConnected()){
    throw new Error('unable to connect to ethereum node at ' + ethereumUri);
}else{
    let coinbase = web3.eth.coinbase;
    console.log('coinbase:' + coinbase);
    let balance = web3.eth.getBalance(coinbase);
    console.log('balance:' + web3.fromWei(balance, 'ether') + " ETH");
    let accounts = web3.eth.accounts;
    console.log(accounts);
    
    if (web3.personal.unlockAccount(address0, '1')) {
        console.log(`${address0} is unlocaked`);
    }else{
        console.log(`unlock failed, ${address0}`);
    }

    if (web3.personal.unlockAccount(address1, '1')) {
      console.log(`${address1} is unlocaked`);
    }else{
      console.log(`unlock failed, ${address1}`);
    }

    if (web3.personal.unlockAccount(address2, '1')) {
      console.log(`${address2} is unlocaked`);
    }else{
      console.log(`unlock failed, ${address2}`);
    }

    if (web3.personal.unlockAccount(address3, '1')) {
      console.log(`${address3} is unlocaked`);
    }else{
      console.log(`unlock failed, ${address3}`);
    }

}


let source = fs.readFileSync("./contracts/CrowdFunding.sol", 'utf8');

console.log('compiling contract...');
let compiledContract = solc.compile(source);
console.log('done');

for (let contractName in compiledContract.contracts) {
    var bytecode = compiledContract.contracts[contractName].bytecode;
    var abi = JSON.parse(compiledContract.contracts[contractName].interface);
}
let gasEstimate = web3.eth.estimateGas({data: '0x' + bytecode});

// https://ethereum.stackexchange.com/questions/55222/uncaught-typeerror-this-eth-sendtransaction-is-not-a-function?rq=1
// https://blog.csdn.net/hdyes/article/details/80818183
var MyContract = web3.eth.contract(abi).at('0xcb75cf88c4a6f7e4f3cc3a0cf38206b73668af36');

var text1 = MyContract.fund({from: address1, gas: 50000 + gasEstimate, value: 7});
// var text2 = MyContract.fund({from: address2, gas: 50000 + gasEstimate, value: 3});
// console.log(text2);
// var text3 = MyContract.fund({from: address3, gas: 50000 + gasEstimate, value: 5});
//var text4 = MyContract.checkGoalReached({from: address0, gas: 50000 + gasEstimate,});
console.log('------------------------------------------------------------');
var now = MyContract.getNow();
var goalAmount = MyContract.getGoalAmountn();

var numInvestors = MyContract.numInvestors();
var deadline = MyContract.DEADLINE();
var status = MyContract.getStatus();
var ended = MyContract.ISEND();
var goalAmount = MyContract.goalAmount();
// var totalAmount = web3.fromWei(MyContract.totalAmount(), 'ether').toNumber();
var totalAmount = MyContract.totalAmount();

console.log('goalAmount = ' + goalAmount);

console.log('numInvestors = ' + numInvestors);
console.log('now = ' + now);
console.log('deadline = ' + deadline);
console.log('status = ' + status);
console.log('ended = ' + ended);
console.log('goalAmount = ' + goalAmount);
console.log('totalAmount = ' + totalAmount);
console.log('------------------------------------------------------------');


// console.log(ended);

// var text7 = web3.fromWei(MyContract.totalAmount(), 'ether');
// console.log(text7.toNumber()); //https://ethereum.stackexchange.com/questions/7656/what-are-c-e-and-s-properties-in-message-call-return-object
