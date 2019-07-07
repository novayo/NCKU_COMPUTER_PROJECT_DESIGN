pragma solidity ^0.4.25;

contract CrowdFunding {
	enum STATUS{
		FUNDING, SUCCESS, FAILED
	}
	// 投資家
	struct Investor {
		string name; // 投資家的位址
		uint amount; // 投資額
		uint restAmount; // 剩餘的錢
	}

	/********** 合約參數 **********/
	string public TERMS_OF_SERVICE = "此智能合約用於P2P借貸平台的一般功能\n\t製作者：施崇祐 陳姿妤 李昱廷（成功大學）\n";
	string public KIND_OF_CONTRACT; // 合約類別
	string public TRANSACTION; // 交易明細
	uint public DURATION; // 剩餘時間（秒）
	uint public DEADLINE; // 截止日期（UnixTime）
	uint public FINISH_TIME; // 完成日期（UnixTime）
	STATUS public status; // 募資活動的狀態

	string public OWNER; // 合約擁有者
	uint public numInvestors; // 投資家數目
	uint public GOALAMOUNT; // 目標金額
	uint public INTEREST; // 目標利率
	uint public PERIODS; // 目標期數

	uint public currentAmount; // 目前投資額
	mapping (uint => Investor) public investors; // 管理投資家的對應表（map）

	modifier aLive () {
		checkGoalReached();
		if (!(status == STATUS.SUCCESS || status == STATUS.FAILED)) _;
		checkGoalReached();
	}

	/// 建構子 (秒, )
	constructor (string _OWNER, uint _GOALAMOUNT, uint _INTEREST, uint _PERIODS, uint _DURATION, string _KIND_OF_CONTRACT) public{
		// 用Unixtime設定截止日期
		KIND_OF_CONTRACT = _KIND_OF_CONTRACT;
		status = STATUS.FUNDING;
		OWNER = _OWNER;
		DEADLINE = now + _DURATION;
		GOALAMOUNT = _GOALAMOUNT;
		INTEREST = _INTEREST;
		PERIODS = _PERIODS;
		DURATION = _DURATION;
		FINISH_TIME = 0;
		numInvestors = 0;
		currentAmount = 0;
		TRANSACTION = "";
	}
	/// 投資時會被呼叫的函數
	function fund(string _name, uint _fundMoney) public payable aLive{
		// 若是活動已結束的話就中斷處理
		if (!(status == STATUS.SUCCESS || status == STATUS.FAILED)){
			Investor inv = investors[numInvestors++];
			inv.name = _name;
			inv.amount = _fundMoney;
			if (currentAmount + inv.amount >= GOALAMOUNT) {
				inv.restAmount = inv.amount - GOALAMOUNT;
				inv.restAmount = inv.restAmount + currentAmount;
				currentAmount = GOALAMOUNT;
			} else {
				inv.restAmount = 0;
				currentAmount += inv.amount;
			}
		}
	}
	/// 確認是否已達成目標金額
	/// 此外，根據活動的成功於否進行ether的匯款
	function checkGoalReached () public {
		if (!(status == STATUS.SUCCESS || status == STATUS.FAILED) || now >= DEADLINE){
			if(currentAmount >= GOALAMOUNT) { // 活動成功的時候
				status = STATUS.SUCCESS;
				FINISH_TIME = now;
			}
			else { // 活動失敗的時候
				if (now >= DEADLINE){
					status = STATUS.FAILED;
				}
			}
			if (!(status == STATUS.SUCCESS || status == STATUS.FAILED)) DURATION = DEADLINE - now;
			else DURATION = 0;
		}
	}

	// name, amount, resamount
	// 回傳：borrowerName&borrowerAmount,investorName&investorAmount,investorName&investorAmount
	function get_TRANSACTION() public view returns(string) {
		if (status == STATUS.SUCCESS){
			TRANSACTION = concatString(TRANSACTION, OWNER);TRANSACTION = concatString(TRANSACTION, ",");
			for (uint i = 0; i<numInvestors; i++) {
				TRANSACTION = concatString(TRANSACTION, investors[i].name);
				if (i < numInvestors-1) TRANSACTION = concatString(TRANSACTION, ",");
			}
			return TRANSACTION;
		} else {
			return "";
		}
	}

	function afterGet_TRANSACTION(string _TRANSACTION) public {
		set_TRANSACTION(_TRANSACTION);
		checkGoalReached();
	}

	function set_TRANSACTION(string _TRANSACTION) internal{
		TRANSACTION = _TRANSACTION;
	}





	/*********************************************************/
	/****************** Getters and Setters ******************/
	/*********************************************************/
	function showAllInfo() public view returns(string) {
		string memory Info = "";
		Info = concatString(Info, "\nTERMS_OF_SERVICE: \n\t");Info = concatString(Info, TERMS_OF_SERVICE);
		Info = concatString(Info, "\nTRANSACTION     : ");Info = concatString(Info, TRANSACTION);
		Info = concatString(Info, "\nKIND_OF_CONTRACT: ");Info = concatString(Info, KIND_OF_CONTRACT);
		Info = concatString(Info, "\nDURATION        : ");Info = concatString(Info, convertIntToString(DURATION));
		Info = concatString(Info, "\nDEADLINE        : ");Info = concatString(Info, convertIntToString(DEADLINE));
		Info = concatString(Info, "\nFINISH_TIME     : ");Info = concatString(Info, convertIntToString(FINISH_TIME));
		Info = concatString(Info, "\nSTATUS          : ");Info = concatString(Info, get_STATUS());
		Info = concatString(Info, "\nOWNER           : ");Info = concatString(Info, OWNER);
		Info = concatString(Info, "\nINTEREST        : ");Info = concatString(Info, convertIntToString(INTEREST));
		Info = concatString(Info, "\nPERIODS         : ");Info = concatString(Info, convertIntToString(PERIODS));
		Info = concatString(Info, "\nGOALAMOUNT      : ");Info = concatString(Info, convertIntToString(GOALAMOUNT));
		Info = concatString(Info, "\nCURRENTAMOUNT   : ");Info = concatString(Info, convertIntToString(currentAmount));
		Info = concatString(Info, "\nNUMINVESTORS    : ");Info = concatString(Info, convertIntToString(numInvestors));
		Info = concatString(Info, "\nINVESTORS: \n");Info = concatString(Info, get_INVESTORS());
		return Info;
	}

	function get_STATUS() public view returns(string) {
		if (status == STATUS.FUNDING){
			return "Funding";
		} else if (status == STATUS.SUCCESS){
			return "Success";
		} else if (status == STATUS.FAILED){
			return "Failed";
		}
	}

	function get_INVESTORS() public view returns(string) {
		string memory Info = "";
		for (uint i = 0; i<numInvestors; i++){
			Info = concatString(Info, "\tname     : ");
			Info = concatString(Info, investors[i].name);Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\ttotalAmount : ");
			Info = concatString(Info, convertIntToString(investors[i].amount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\trestAmount  : ");
			Info = concatString(Info, convertIntToString(investors[i].restAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t----------------------------------------------------------------\n");
		}
		return Info;
	}




	/*********************************************************/
	/********************      Utils      ********************/
	/*********************************************************/
	function concatString(string a, string b) internal pure returns (string) {
    	return string(abi.encodePacked(a, b));
	}

	function compareString(string s1, string s2) internal pure returns(bool){
		if (keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))) return true;
		else return false;
	}

	function convertIntToString(uint _number) internal pure returns (string) {
		// https://ethereum.stackexchange.com/questions/59128/error-security-no-assign-param-avoid-assigning-to-function-parameters
		uint _tmpN = _number;
		if (_tmpN == 0) {
			return "0";
		}
		uint j = _tmpN;
		uint length = 0;

		while (j != 0){
			length++;
			j /= 10;
		}

		bytes memory bstr = new bytes(length);
		uint k = length - 1;

		while (_tmpN != 0) {
			bstr[k--] = byte(48 + _tmpN % 10);
			_tmpN /= 10;
		}

		return string(bstr);
	}
}

