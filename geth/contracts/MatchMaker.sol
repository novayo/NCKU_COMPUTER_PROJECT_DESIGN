pragma solidity ^0.4.11;

contract MatchMaker {
	enum ID{
		INVESTOR, BORROWER
	}
	enum STATUS{
		WAITING, DOING_MATCH, SUCCESS, FAILED
	}

	// 投資家
	struct Investor {
		string addr; // 投資家的位址
		uint totalAmount; // 投資額
        uint restAmount; // 餘額
        uint interest; // 要求利率(由於沒有支援浮點數，因此要再討論傳進來的格式)
		uint creditRating; // 信用評價
	}
	struct Borrower {
		string addr; //借錢人的位址
		uint totalAmount; // 借錢總額
        uint restAmount; // 借錢餘額
        uint interest; // 要求利率(由於沒有支援浮點數，因此要再討論傳進來的格式)
		uint creditRating; // 信用評價
	}
	string kindOfConteact;
	uint private DEADLINE; // 截止日期（UnixTime）
	STATUS private status; // 募資活動的狀態
	bool private ISEND; // 募資活動是否已終了

	uint private numInvestors; // 投資家數目
	uint private numBorrowers; // 借錢家數目

	mapping (uint => Investor) private investors; // 管理投資家的對應表（map）
	mapping (uint => Borrower) private borrowers; // 管理投資家的對應表（map）

	modifier aLive () {
		if (!ISEND) {
			//checkGoalReached();
			_;
		}
	}

	/// 建構子 (秒, 錢)
	constructor (string _kindOfConteact, uint _duration) {
		kindOfConteact = _kindOfConteact;
		DEADLINE = now + _duration; // 用Unixtime設定截止日期
		status = STATUS.WAITING;
		ISEND = false;
		numInvestors = 0;
		numBorrowers = 0;
	}

	function addUserInContract (string _id, string _addr, uint _totalAmount, uint _interest, uint _creditRating) public aLive{
		if (compareString(_id,'INVESTOR')){
			Investor inv = investors[numInvestors++];
			inv.addr = _addr;
			inv.totalAmount = _totalAmount;
			inv.restAmount = _totalAmount;
			inv.interest = _interest;
			inv.creditRating = _creditRating;
		} else if (compareString(_id, 'BORROWER')){
			Borrower bor = borrowers[numBorrowers++];
			bor.addr = _addr;
			bor.totalAmount = _totalAmount;
			bor.restAmount = _totalAmount;
			bor.interest = _interest;
			bor.creditRating = _creditRating;
		}
	}

	function test() public returns(string){
		// sortFromBigToSmall();
	}

	/// 投資時會被呼叫的函數
	// function fund() payable {
	// 	// 若是活動已結束的話就中斷處理
	// 	checkGoalReached();
	// 	if (!ISEND){
	// 		Investor inv = investors[numInvestors++];
	// 		inv.addr = msg.sender;
	// 		inv.totalAmount = msg.value;
	// 		totalAmount += inv.totalAmount;
    //         if (totalAmount >= goalAmount){
    //             totalAmount = goalAmount;
    //             checkGoalReached();
    //         }
	// 	}
	// }

	// /// 確認是否已達成目標金額
	// /// 此外，根據活動的成功於否進行ether的匯款
	// function checkGoalReached () private{
	// 	if (!ISEND || now >= DEADLINE){
	// 		if(totalAmount >= goalAmount) { // 活動成功的時候
	// 			status = "Campaign Succeeded";
	// 			ISEND = true;
	// 			// 將合約內所有以太幣（ether）傳送給所有人
	// 			// if(!owner.send(this.balance)) {
	// 			// 	throw;
	// 			// }
	// 		}
	// 		else { // 活動失敗的時候
	// 			if (now >= DEADLINE){
	// 				uint i = 0;
	// 				status = "Campaign Failed";
	// 				ISEND = true;
	// 				// 將ether退款給每位投資家
	// 				// while(i <= numInvestors) {
	// 				// 	if(!investors[i].addr.send(investors[i].amount)) {
	// 				// 		throw;
	// 				// 	}
	// 				//     i++;
	// 				//     }
	// 			}
	// 		}
	// 	}
	// }

	function showAllInfo() public view returns(string) {
		string memory Info = "";
		Info = concatString(Info, "\nINVESTORS : \n");
		for (uint i = 0; i<numInvestors; i++){
			Info = concatString(Info, "\taddress     : ");
			Info = concatString(Info, investors[i].addr);Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\ttotalAmount : ");
			Info = concatString(Info, convertIntToString(investors[i].totalAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\trestAmount  : ");
			Info = concatString(Info, convertIntToString(investors[i].restAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tinterest    : ");
			Info = concatString(Info, convertIntToString(investors[i].interest));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tcreditRating    : ");
			Info = concatString(Info, convertIntToString(investors[i].creditRating));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t----------------------------------------------------------------\n");
		}
		Info = concatString(Info, "\nBORROWERS : \n");
		for (i = 0; i < numBorrowers; i++){
			Info = concatString(Info, "\taddress     : ");
			Info = concatString(Info, borrowers[i].addr);Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\ttotalAmount : ");
			Info = concatString(Info, convertIntToString(borrowers[i].totalAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\trestAmount  : ");
			Info = concatString(Info, convertIntToString(borrowers[i].restAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tinterest    : ");
			Info = concatString(Info, convertIntToString(borrowers[i].interest));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tcreditRating    : ");
			Info = concatString(Info, convertIntToString(borrowers[i].creditRating));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t----------------------------------------------------------------\n");
		}
		return Info;
	}

    function getNumInvestors() public view returns(uint) {
		return numInvestors;
	}

    function getDEADLINE() public view returns(uint) {
		return DEADLINE;
	}

    function getstatus() public view returns(string) {
		if (status == STATUS.WAITING){
			return "Waiting";
		} else if (status == STATUS.DOING_MATCH){
			return "Doing_Match";
		} else if (status == STATUS.SUCCESS){
			return "Success";
		} else if (status == STATUS.FAILED){
			return "Failed";
		}
	}

    function getISEND() public view returns(bool) {
		return ISEND;
	}

	function concatString(string a, string b) private pure returns (string) {
    	return string(abi.encodePacked(a, b));
	}

	function compareString(string s1, string s2) private returns(bool){
		if (keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))) return true;
		else return false;
	}

	function convertIntToString(uint _number) private view returns (string) {
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




	uint[] empty;
	uint[] startIndex_for_borrowers;
	/*************************  信用評價還沒加 *************************/
	function make_a_match() public view returns(string){
		string memory Info = "";
		sortedUsers(true, true); // 依照利率由高到低排序好投資方跟借錢人
		checkEqualAmount(); // 比較相等的金錢的雙方
		Info = concatString(Info, "\n\n");
		Info = concatString(Info, showAllInfo());
		updateCluster();
		for (uint i = 0; i<numBorrowers; i++){
			Info = concatString(Info, convertIntToString(startIndex_for_borrowers[i]));
			Info = concatString(Info, " ");
			if (startIndex_for_borrowers[i] == 99) continue;
			uint startIndex = startIndex_for_borrowers[i];
			for (uint j = startIndex; j<numInvestors; j++){
				if (borrowers[i].restAmount == 0 || investors[j].restAmount == 0) break; // 若borrower的錢給完了，或是investor的錢都歸0了
				if (investors[j].restAmount > borrowers[i].restAmount){ // case 1：要求的利率下，investor的錢比borrower的多
					investors[j].restAmount -= borrowers[i].restAmount;
					borrowers[i].restAmount = 0;
					borrowers[i].interest = 0;
					Info = concatString(Info, "\n");
					Info = addInTransactionRecord(Info, i, j);
				} else if (investors[j].restAmount == borrowers[i].restAmount){ // case 3：要求的利率下，investor的錢 == borrower的錢
					investors[j].restAmount = 0;
					investors[j].interest = 0;
					borrowers[i].restAmount = 0;
					borrowers[i].interest = 0;
					Info = concatString(Info, "\n");
					Info = addInTransactionRecord(Info, i, j);
				} else { // case 3：要求的利率下，investor的錢 < borrower的錢
					borrowers[i].restAmount -= investors[j].restAmount;
					investors[j].restAmount = 0;
					investors[j].interest = 0;
					Info = concatString(Info, "\n");
					Info = addInTransactionRecord(Info, i, j);
				}
			}
			Info = concatString(Info, "\n");
			sortedUsers(true, false); // sort investor
			updateCluster();
		}


		sortedUsers(true, true); // sort investor
		Info = concatString(Info, "\n\n");
		Info = concatString(Info, showAllInfo());
    	return Info;
	}

	uint[] arr;	// 要寫在外面，寫在function內會出錯==
	uint tmpPreIndex;
	uint tmpInterest;
	function sortedUsers(bool sortInvestor, bool sortBorrower) private view {
		if (sortInvestor){
			// 排序利息
			arr = empty;
			for (uint i = 0; i<numInvestors; i++){
				arr.push(investors[i].interest);
			}
			sortFromBigToSmall(arr, ID.INVESTOR, 0);

			// 相同利息排序金錢
			arr = empty;
			tmpInterest = investors[0].interest;
			tmpPreIndex = 0;
			for (i = 0; i < numInvestors; i++){
				if (investors[i].interest == tmpInterest){
					arr.push(investors[i].restAmount);
				} else {
					sortFromBigToSmall(arr, ID.INVESTOR, tmpPreIndex);
					tmpInterest = investors[i].interest;
					arr = empty;
					tmpPreIndex = i;
					i--;
				}
			}
			sortFromBigToSmall(arr, ID.INVESTOR, tmpPreIndex);
		}

		if (sortBorrower){
			// 排序利息
			arr = empty;
			for (i = 0; i < numBorrowers; i++){
				arr.push(borrowers[i].interest);
			}
			sortFromBigToSmall(arr, ID.BORROWER, 0);

			// 相同利息排序金錢
			arr = empty;
			tmpInterest = borrowers[0].interest;
			for (i = 0; i < numBorrowers; i++){
				if (borrowers[i].interest == tmpInterest){
					arr.push(borrowers[i].restAmount);
				} else {
					sortFromBigToSmall(arr, ID.BORROWER, tmpPreIndex);
					tmpInterest = borrowers[i].interest;
					arr = empty;
					tmpPreIndex = i;
					i--;
				}
			}
			sortFromBigToSmall(arr, ID.BORROWER, tmpPreIndex);
			arr = empty;
		}

	}

	// https://gist.github.com/subhodi/b3b86cc13ad2636420963e692a4d896f
	// 這個sort不會改變原本的investors跟borrowers的array順序
	function sortFromBigToSmall(uint[] data, ID _id, uint preIndex) public view returns(uint[]) {
    	if (data.length > 1) quickSort(data, int(0), int(data.length - 1), _id, preIndex);
		return data;
    }
    function quickSort(uint[] memory arr, int left, int right, ID _id, uint preIndex) private{
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] > pivot) i++;
            while (pivot > arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);

				// 交換investor，由於他是指標，所以都不能直接用暫存的方式，只能找一個位置來當作暫存
				// uint256(-1) 好像 uint是到不了的
				if (_id == ID.INVESTOR){
					investors[uint256(9999)] = investors[uint(i) + preIndex];
					investors[uint(i) + preIndex] = investors[uint(j) + preIndex];
					investors[uint(j) + preIndex] = investors[uint256(9999)];
				} else if (_id == ID.BORROWER){
					borrowers[uint256(9999)] = borrowers[uint(i) + preIndex];
					borrowers[uint(i) + preIndex] = borrowers[uint(j) + preIndex];
					borrowers[uint(j) + preIndex] = borrowers[uint256(9999)];
				}
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j, _id, preIndex);
        if (i < right)
            quickSort(arr, i, right, _id, preIndex);
    }

	function checkEqualAmount() private view {
		for (uint i = 0; i<numBorrowers; i++){
			if (borrowers[i].restAmount == 0) break;
			for (uint j = 0; j<numInvestors; j++){
				if (investors[j].restAmount == 0) break;
				if (borrowers[i].totalAmount == investors[j].totalAmount){
					borrowers[i].restAmount = 0;
					investors[j].restAmount = 0;
					borrowers[i].interest = 0; // 為了排序的時候會跑到最後面，因此要歸0
					investors[j].interest = 0;
					sortedUsers(true, true);
					i--; // 因為這個borrower重新sorted跑到最後面了，所以同一個位置要從新弄
					break;
				}
			}
		}
	}

	function updateCluster() private view {
		startIndex_for_borrowers = empty;
		bool isNotPush = true;
		for (uint i = 0; i<numBorrowers; i++){
			if (borrowers[i].restAmount == 0) {
				startIndex_for_borrowers.push(99);
				continue;
			}
			for (uint j = 0; j<numInvestors; j++){
				if (investors[j].restAmount == 0) break;
				if (borrowers[i].interest >= investors[j].interest){
					startIndex_for_borrowers.push(j);
					isNotPush = false;
					break;
				}
			}
			if (isNotPush) { // borrowers.interest < all investors.interest
				startIndex_for_borrowers.push(99);
			}
		}
	}

	function addInTransactionRecord(string input, uint indexBorrower, uint indexInvestor) private view returns(string){
		string memory newRecord = concatString(input, convertIntToString(borrowers[indexBorrower].restAmount));
		newRecord = concatString(newRecord, " - ");
		newRecord = concatString(newRecord, convertIntToString(investors[indexInvestor].restAmount));
		newRecord = concatString(newRecord, "\n");
		return newRecord;
	}

}

