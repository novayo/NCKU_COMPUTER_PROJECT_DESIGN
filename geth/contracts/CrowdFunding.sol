pragma solidity ^0.4.11;
contract CrowdFunding {
	enum STATUS{
		FUNDING, SUCCESS, FAILED
	}
	// 投資家
	struct Investor {
		address addr; // 投資家的位址
		uint amount; // 投資額
	}
	uint public DEADLINE; // 截止日期（UnixTime）
	STATUS public status; // 募資活動的狀態
	bool public ISEND; // 募資活動是否已終了

	address public owner; // 合約所有人
	uint public numInvestors; // 投資家數目
	uint public goalAmount; // 目標額
	uint public totalAmount; // 投資總額
	mapping (uint => Investor) public investors; // 管理投資家的對應表（map）

	modifier aLive () {
		if (!ISEND) {
			_;
			checkGoalReached();
		}
	}

	/// 建構子 (秒, )
	function CrowdFunding(uint _duration, uint _goalAmount) {
		owner = msg.sender;
		// 用Unixtime設定截止日期
		DEADLINE = now + _duration;
		goalAmount = _goalAmount;
		status = STATUS.FUNDING;
		ISEND = false;
		numInvestors = 0;
		totalAmount = 0;
	}
	/// 投資時會被呼叫的函數
	function fund() payable public aLive{
		// 若是活動已結束的話就中斷處理
		if (!ISEND){
			Investor inv = investors[numInvestors++];
			inv.addr = msg.sender;
			inv.amount = msg.value;
			totalAmount += inv.amount;
		}
	}
	/// 確認是否已達成目標金額
	/// 此外，根據活動的成功於否進行ether的匯款
	function checkGoalReached () public {
		if (!ISEND || now >= DEADLINE){
			if(totalAmount >= goalAmount) { // 活動成功的時候
				status = STATUS.SUCCESS;
				ISEND = true;
				// 將合約內所有以太幣（ether）傳送給所有人
				// if(!owner.send(this.balance)) {
				// 	throw;
				// }
			} 
			
			else { // 活動失敗的時候
				if (now >= DEADLINE){
				// uint i = 0;
				status = STATUS.FAILED;
				ISEND = true;
				// 將ether退款給每位投資家
				// while(i <= numInvestors) {
				// 	if(!investors[i].addr.send(investors[i].amount)) {
				// 		throw;
				// 	}
				// i++;
				// }
				}
			}
		}
	}

	function getNow() constant public returns(uint) {
		return now;
	}

	function getStatus() constant public returns(string) {
		if (status == STATUS.FUNDING){
			return "Funding";
		} else if (status == STATUS.SUCCESS){
			return "Success";
		} else if (status == STATUS.FAILED){
			return "Failed";
		} 
	}

	function getGoalAmountn() constant public returns(uint) {
		return goalAmount;
	}

    /*
	/// 為了銷毀合約的函數
	function kill() public onlyOwner {
		selfdestruct(owner);
	}
    */
}

