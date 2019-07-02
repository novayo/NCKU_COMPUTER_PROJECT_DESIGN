const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');

const demo = 1; // 0 for print nothing

/*
 * connect to ethereum node
 */ 
const ethereumUri = 'http://localhost:8545';


var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider(ethereumUri));
const account0 = web3.eth.accounts[0]; // user
if(!web3.isConnected()){
    throw new Error('unable to connect to ethereum node at ' + ethereumUri);
}else{
    if (demo == 1) console.log('connected to ehterum node at ' + ethereumUri);
    let coinbase = web3.eth.coinbase;
    if (demo == 1) console.log('coinbase:' + coinbase);
    let balance = web3.eth.getBalance(coinbase);
    if (demo == 1) console.log('balance:' + web3.fromWei(balance, 'ether') + " ETH");
    let accounts = web3.eth.accounts;
    if (demo == 1) console.log(accounts);
    
    if (web3.personal.unlockAccount(account0, '1')) {
        if (demo == 1) console.log(`${account0} is unlocaked`);
    }else{
        if (demo == 1) console.log(`unlock failed, ${account0}`);
    }
}

/*
* Compile Contract and Fetch ABI
*/ 
function deploy_contract(contract_Name, duration, index, callback){
    let name = contract_Name;
    let source = fs.readFileSync("./contracts/" + name, 'utf8');

    if (demo == 1) console.log('compiling contract...');
    let compiledContract = solc.compile(source);
    if (demo == 1) console.log('done');

    for (let contractName in compiledContract.contracts) {
        // code and ABI that are needed by web3 
        // if (demo == 1) console.log(contractName + ': ' + compiledContract.contracts[contractName].bytecode);
        // if (demo == 1) console.log(contractName + '; ' + JSON.parse(compiledContract.contracts[contractName].interface));
        var bytecode = compiledContract.contracts[contractName].bytecode;
        var abi = JSON.parse(compiledContract.contracts[contractName].interface);
    }

    if (demo == 1) console.log(JSON.stringify(abi, undefined, 2));

    /*
    * deploy contract
    */ 
    let gasEstimate = web3.eth.estimateGas({data: '0x' + bytecode});
    if (demo == 1) console.log('gasEstimate = ' + gasEstimate);

    let MyContract = web3.eth.contract(abi);
    if (demo == 1) console.log('deploying contract...');

    //(秒, 錢)
    let myContractReturned = MyContract.new(duration, index, {
        from: account0,
        data: '0x'+ bytecode,
        gas: gasEstimate + 50000,
    }, function (err, myContract) {
        if (!err) {
            // NOTE: The callback will fire twice!
            // Once the contract has the transactionHash property set and once its deployed on an address.

            // e.g. check tx hash on the first call (transaction send)
            if (!myContract.address) {
                if (demo == 1) console.log(`myContract.transactionHash = ${myContract.transactionHash}`); // The hash of the transaction, which deploys the contract
            
            // check address on the second call (contract deployed)
            } else {
                global.contractAddress = myContract.address;
                if (demo == 1) console.log('myContract.address = ' + myContract.address);
                callback(myContract.address); // http://larry850806.github.io/2016/06/16/nodejs-async/
            }
                

            // Note that the returned "myContractReturned" === "myContract",
            // so the returned "myContractReturned" object will also get the address set.
        } else {
                if (demo == 1) console.log(err);
        }
    });

    return myContractReturned;
}

function deploy_matchmaker_contract(_duration, _kindOfContract){
    deploy_contract("MatchMaker.sol", _duration, _kindOfContract, function(RETURN_ADDRESS){
        /*
         * Return ADDRESS to MySql
         */
         console.log(RETURN_ADDRESS);
    });
}

function deploy_crowdfunding_contract(_duration, _totalAmount){
    deploy_contract("CrowdFunding.sol", _duration, _totalAmount);
}

deploy_matchmaker_contract(600, "INVESTOR");
// deploy_crowdfunding_contract(600, 10000);