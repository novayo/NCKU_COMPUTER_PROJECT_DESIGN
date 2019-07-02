const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');
const ethereumUri = 'http://localhost:8545';
const demo = 0;

var addr = "0x1a03c26f81cd0f301e57d2bc8beae777f0d9fc5b";
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider(ethereumUri));
const address0 = web3.eth.accounts[0];// user
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
// showAllInfo();
// test();
console.log(_make_a_match());
/*********************************************************/



function addUser(User_ID, User_Name, User_TotalAmount, User_Interest, User_CreditRating) {
  // update this value in order to do something to aimmed contract
  var value = getContractInfo(addr);
  value[0].addUserInContract(User_ID, User_Name, User_TotalAmount, User_Interest, User_CreditRating.charCodeAt(0), { from: address0, gas: value[1] });
}

function _make_a_match() {
  // update this value in order to do something to aimmed contract
  var value = getContractInfo(addr);
  // console.log(value);
  var result = value[0].make_a_match();
  var data = parseString(result);
  console.log(value[0].getIsend());
  console.log(value[0].getStatus());
  return data;
  // [資料]
  // [[第n筆資料]]
  // [[[貸款人, 借款人]]]
}

function showAllInfo() {
  var value = getContractInfo(addr);
  console.log(value[0].showAllInfo());
}




function test() {
  addUser('INVESTOR', "施崇祐", 260000, 11, "A");
  addUser('INVESTOR', "陳姿妤", 220000, 22, "B");
  addUser('INVESTOR', "李昱廷", 700000, 33, "B");
  addUser('INVESTOR', "蔡英文", 250000, 11, "B");
  addUser('INVESTOR', "馬英九", 1, 11, "B");
  addUser('INVESTOR', "小紅帽", 1, 11, "C");
  addUser('INVESTOR', "艾希", 1, 11, "B");

  addUser('BORROWER', "法洛士", 200000, 11, "A");
  addUser('BORROWER', "咸蛋超人", 500000, 11, "A");
  // MyContract.addUserInContract('INVESTOR',address0, 260000, 11,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('INVESTOR',address0, 220000, 22,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('INVESTOR',address0, 700000, 33,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('INVESTOR',address0, 250000, 11,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('INVESTOR',address0, 1, 11,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('INVESTOR',address0, 1, 11,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('INVESTOR',address0, 1, 11,{from: address0, gas: 300000 + gasEstimate});


  // // MyContract.addUserInContract('BORROWER',address0, 500000, 33,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('BORROWER',address0, 200000, 11,{from: address0, gas: 300000 + gasEstimate});
  // MyContract.addUserInContract('BORROWER',address0, 500000, 11,{from: address0, gas: 300000 + gasEstimate});
}



/*********************************************************/
/********************      Utils      ********************/
/*********************************************************/
function getContractInfo(Contract_Address) {
  let source = fs.readFileSync("./contracts/MatchMaker.sol", 'utf8');
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

function parseString(result) {
  var data = [];
  var tmp = result.split("|");
  tmp = tmp.slice(1);
  for (let index in tmp) {
    var tmpData = [];
    var ttmp = tmp[index].split(",");
    for (let j in ttmp) {
      var tttmp = ttmp[j].split("&");
      tttmp[4] = String.fromCharCode(tttmp[4]);
      tmpData.push(tttmp);
    }
    data.push(tmpData);
  }
  return data;
}





// let web3 = new Web3();
// web3.setProvider(new web3.providers.HttpProvider(ethereumUri));
// const address0 = web3.eth.accounts[0]; // user
// if(!web3.isConnected()){
//     throw new Error('unable to connect to ethereum node at ' + ethereumUri);
// }else{
//     let coinbase = web3.eth.coinbase;
//     if (demo == 1) console.log('coinbase:' + coinbase);
//     let balance = web3.eth.getBalance(coinbase);
//     if (demo == 1) console.log('balance:' + web3.fromWei(balance, 'ether') + " ETH");
//     let accounts = web3.eth.accounts;
//     if (demo == 1) console.log(accounts);

//     if (web3.personal.unlockAccount(address0, '1')) {
//         if (demo == 1) console.log(`${address0} is unlocaked`);
//     }else{
//         if (demo == 1) console.log(`unlock failed, ${address0}`);
//     }

// }

// let source = fs.readFileSync("./contracts/MatchMaker.sol", 'utf8');

// if (demo == 1) console.log('compiling contract...');
// let compiledContract = solc.compile(source);
// if (demo == 1) console.log('done');

// for (let contractName in compiledContract.contracts) {
//     var bytecode = compiledContract.contracts[contractName].bytecode;
//     var abi = JSON.parse(compiledContract.contracts[contractName].interface);
// }
// let gasEstimate = web3.eth.estimateGas({data: '0x' + bytecode});

// // https://ethereum.stackexchange.com/questions/55222/uncaught-typeerror-this-eth-sendtransaction-is-not-a-function?rq=1
// // https://blog.csdn.net/hdyes/article/details/80818183
// var MyContract = web3.eth.contract(abi).at('0x24eb17fcdd945546d9093775ea4d420bb2e0fe81');

// MyContract.addUserInContract('INVESTOR',address0, 260000, 11,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('INVESTOR',address0, 220000, 22,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('INVESTOR',address0, 700000, 33,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('INVESTOR',address0, 250000, 11,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('INVESTOR',address0, 1, 11,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('INVESTOR',address0, 1, 11,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('INVESTOR',address0, 1, 11,{from: address0, gas: 300000 + gasEstimate});


// // MyContract.addUserInContract('BORROWER',address0, 500000, 33,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('BORROWER',address0, 200000, 11,{from: address0, gas: 300000 + gasEstimate});
// MyContract.addUserInContract('BORROWER',address0, 500000, 11,{from: address0, gas: 300000 + gasEstimate});

// if (demo == 1) console.log('------------------------------------------------------------');
// // var now = MyContract.getNow();
// // var goalAmount = MyContract.getGoalAmountn();
// // var numInvestors = MyContract.numInvestors();
// var deadline = MyContract.getDEADLINE();
// var test = MyContract.test();
// // var info = MyContract.showAllInfo();

// // var status = MyContract.getStatus();
// // var ended = MyContract.ISEND();
// // var goalAmount = MyContract.goalAmount();
// // // var totalAmount = web3.fromWei(MyContract.totalAmount(), 'ether').toNumber();
// // var totalAmount = MyContract.totalAmount();

// // if (demo == 1) console.log('goalAmount = ' + goalAmount);

// // if (demo == 1) console.log('numInvestors = ' + numInvestors);
// // if (demo == 1) console.log('now = ' + now);
// if (demo == 1) console.log('deadline = ' + deadline);
// if (demo == 1) console.log(test);

// // if (demo == 1) console.log('------------------------------------------------------------');
// // if (demo == 1) console.log('------------------------------------------------------------');
// // if (demo == 1) console.log('\n' + info);
// // if (demo == 1) console.log('status = ' + status);
// // if (demo == 1) console.log('ended = ' + ended);
// // if (demo == 1) console.log('goalAmount = ' + goalAmount);
// // if (demo == 1) console.log('totalAmount = ' + totalAmount);
// if (demo == 1) console.log('------------------------------------------------------------');


// // if (demo == 1) console.log(ended);

// // var text7 = web3.fromWei(MyContract.totalAmount(), 'ether');
// // if (demo == 1) console.log(text7.toNumber()); //https://ethereum.stackexchange.com/questions/7656/what-are-c-e-and-s-properties-in-message-call-return-object
