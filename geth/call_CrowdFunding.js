const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');
const ethereumUri = 'http://localhost:8545'; 
const MyContract = value[0];
const gasEstimate = value[1];


const demo = 1;
let web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider(ethereumUri));
const address0 =  web3.eth.accounts[0];// user
if (!web3.isConnected()) {
  throw new Error('unable to connect to ethereum node at ' + ethereumUri);
} else {
  let coinbase = web3.eth.coinbase;
  if (demo == 1) console.log('coinbase:' + coinbase);
  let balance = web3.eth.getBalance(coinbase);
  if (demo == 1) console.log('balance:' + web3.fromWei(balance, 'ether') + " ETH");
  let accounts = web3.eth.accounts;
  if (demo == 1) console.log(accounts);

  if (web3.personal.unlockAccount(address0, '1')) {
    if (demo == 1) console.log(`${address0} is unlocaked`);
  } else {
    if (demo == 1) console.log(`unlock failed, ${address0}`);
  }
}

/*********************************************************/
fund(7);
/*********************************************************/



function fund(_fundMoney){
  var value = getContractInfo("0xce51f0c98ae9c32509b253e1f5832acc2564822c"); 
  value[0].fund({from: address0, gas: value[1], value: _fundMoney});
}




/*********************************************************/
/********************      Utils      ********************/
/*********************************************************/
function getContractInfo(Contract_Address) {
  let source = fs.readFileSync("./contracts/CrowdFunding.sol", 'utf8');
  if (demo == 1) console.log('compiling contract...');
  let compiledContract = solc.compile(source);
  if (demo == 1) console.log('done');

  for (let contractName in compiledContract.contracts) {
    var bytecode = compiledContract.contracts[contractName].bytecode;
    var abi = JSON.parse(compiledContract.contracts[contractName].interface);
  }
  let gasestimate = web3.eth.estimateGas({ data: '0x' + bytecode }) + 300000;

  // https://ethereum.stackexchange.com/questions/55222/uncaught-typeerror-this-eth-sendtransaction-is-not-a-function?rq=1
  // https://blog.csdn.net/hdyes/article/details/80818183
  var contract = web3.eth.contract(abi).at(Contract_Address);
  return [contract, gasestimate];
}










// var text2 = MyContract.fund({from: address2, gas: 50000 + gasEstimate, value: 3});
// if (demo == 1) console.log(text2);
// var text3 = MyContract.fund({from: address3, gas: 50000 + gasEstimate, value: 5});
//var text4 = MyContract.checkGoalReached({from: address0, gas: 50000 + gasEstimate,});
// if (demo == 1) console.log('------------------------------------------------------------');
// var now = MyContract.getNow();
// var goalAmount = MyContract.getGoalAmountn();

// var numInvestors = MyContract.numInvestors();
// var deadline = MyContract.DEADLINE();
// var status = MyContract.getStatus();
// var ended = MyContract.ISEND();
// var goalAmount = MyContract.goalAmount();
// // var totalAmount = web3.fromWei(MyContract.totalAmount(), 'ether').toNumber();
// var totalAmount = MyContract.totalAmount();

// if (demo == 1) console.log('goalAmount = ' + goalAmount);

// if (demo == 1) console.log('numInvestors = ' + numInvestors);
// if (demo == 1) console.log('now = ' + now);
// if (demo == 1) console.log('deadline = ' + deadline);
// if (demo == 1) console.log('status = ' + status);
// if (demo == 1) console.log('ended = ' + ended);
// if (demo == 1) console.log('goalAmount = ' + goalAmount);
// if (demo == 1) console.log('totalAmount = ' + totalAmount);
// if (demo == 1) console.log('------------------------------------------------------------');


// if (demo == 1) console.log(ended);

// var text7 = web3.fromWei(MyContract.totalAmount(), 'ether');
// if (demo == 1) console.log(text7.toNumber()); //https://ethereum.stackexchange.com/questions/7656/what-are-c-e-and-s-properties-in-message-call-return-object
