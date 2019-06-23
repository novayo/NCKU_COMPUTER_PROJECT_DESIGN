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
var MyContract = web3.eth.contract(abi).at('0x2c515f89cccabae261102496479101a8a2dc9170');

//var text1 = MyContract.fund({from: address1, gas: 50000 + gasEstimate, value: web3.toWei(1, "ether")});
//var text2 = MyContract.fund({from: address2, gas: 50000 + gasEstimate, value: web3.toWei(3, "ether")});
//var text3 = MyContract.fund({from: address3, gas: 50000 + gasEstimate, value: web3.toWei(5, "ether")});
//var text4 = MyContract.checkGoalReached({from: address0, gas: 50000 + gasEstimate,});

var text5 = MyContract.ended();
console.log(text5);
var text6 = MyContract.status();
console.log(text6);
var text7 = web3.fromWei(MyContract.totalAmount(), 'ether');
console.log(text7.toNumber()); //https://ethereum.stackexchange.com/questions/7656/what-are-c-e-and-s-properties-in-message-call-return-object
