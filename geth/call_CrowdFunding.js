const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');
const ethereumUri = 'http://localhost:8545';  
const demo = 0;


var addr = "0xa9d190b2d58092fff53ccb590de9e5c10370daa6";
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
fund(7); // 錢
/*********************************************************/



function fund(_fundMoney){
  var value = getContractInfo(addr); 
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