const fs = require('fs');
var gensis = JSON.parse(fs.readFileSync("gensis.json"));
var read = fs.readFile('.newAccountLog.txt', 'utf8', function(err, data){
    delete gensis.alloc;
    var newAlloc = {};
    newAlloc[data.substring(10, data.length-2).toString()] = {};
    newAlloc[data.substring(10, data.length-2).toString()]['balance'] = '100000000000000000000';
    gensis['alloc'] = newAlloc;
    fs.writeFileSync('gensis.json', JSON.stringify(gensis));
});