const fs = require('fs');
var gensis = JSON.parse(fs.readFileSync(__dirname + "/gensis.json", 'utf8'));
var read = fs.readFile(__dirname + '/.newAccountLog.txt', 'utf8', function(err, data){
    data = data.substring(10, data.length-2).toString();
    delete gensis.alloc;
    var newAlloc = {};
    newAlloc[data] = {};
    newAlloc[data]['balance'] = '100000000000000000000';
    gensis['alloc'] = newAlloc;
    fs.writeFileSync(__dirname + '/gensis.json', JSON.stringify(gensis));
});