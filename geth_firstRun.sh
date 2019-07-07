rm -rf "./db"
bash -c 'geth account new --password <(echo 1) --datadir="./db" > ./utils/.newAccountLog.txt' # https://unix.stackexchange.com/questions/151911/syntax-error-near-unexpected-token
node ./utils/addDefaultAccount_In_Gensis.js
geth --datadir "./db" init "./utils/gensis.json"