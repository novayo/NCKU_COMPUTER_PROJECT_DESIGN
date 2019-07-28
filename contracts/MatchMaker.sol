pragma solidity ^0.4.25;

contract MatchMaker {
	enum ID{
		INVESTOR, BORROWER
	}
	enum STATUS{
		WAITING, DOING_MATCH, SUCCESS, FAILED
	}

	// 投資家
	struct Investor {
		string name; // 投資家的位址
		uint totalAmount; // 投資額
        uint restAmount; // 餘額
        uint interest; // 要求利率(由於沒有支援浮點數，因此要再討論傳進來的格式)
		uint creditRating; // 信用評價（用ABCDE）
	}
	struct Borrower {
		string name; //借錢人的位址
		uint totalAmount; // 借錢總額
        uint restAmount; // 借錢餘額
        uint interest; // 要求利率(由於沒有支援浮點數，因此要再討論傳進來的格式)
		uint creditRating; // 信用評價（用ABCDE）
	}

	/********** 合約參數 **********/
	string public TERMS_OF_SERVICE = "此智能合約用於P2P借貸平台的撮合功能\n\t製作者：施崇祐 陳姿妤 李昱廷（成功大學）\n";
	string public TRANSACTION = "";
	string public KIND_OF_CONTRACT; // 合約類別
	uint public DURATION; // 剩餘時間（秒）
	uint public DEADLINE; // 截止日期（UnixTime）
	uint public FINISH_TIME; // 完成日期（UnixTime）
	STATUS public status; // 募資活動的狀態
	string newRecord = "";


	uint public numInvestors; // 投資家數目
	uint public numBorrowers; // 借錢家數目
	mapping (uint => Investor) public investors; // 管理投資家的對應表（map）
	mapping (uint => Borrower) public borrowers; // 管理投資家的對應表（map）

	modifier aLive () {
		if (!(status == STATUS.SUCCESS || status == STATUS.FAILED)) _;
	}

	/// 建構子 (秒, 錢)
	constructor (uint _duration, string _KIND_OF_CONTRACT) public{
		KIND_OF_CONTRACT = _KIND_OF_CONTRACT;
		DURATION = _duration;
		DEADLINE = now + _duration; // 用Unixtime設定截止日期
		FINISH_TIME = 0;
		status = STATUS.WAITING;
		numInvestors = 0;
		numBorrowers = 0;
		newRecord = concatString(TRANSACTION, "|");
	}

	function addUserInContract (string _id, string _name, uint _totalAmount, uint _interest, uint _creditRating) public aLive{
		if (compareString(_id, 'INVESTOR')){
			Investor inv = investors[numInvestors++];
			inv.name = _name;
			inv.totalAmount = _totalAmount;
			inv.restAmount = _totalAmount;
			inv.interest = _interest;
			inv.creditRating = _creditRating;
		} else if (compareString(_id, 'BORROWER')){
			Borrower bor = borrowers[numBorrowers++];
			bor.name = _name;
			bor.totalAmount = _totalAmount;
			bor.restAmount = _totalAmount;
			bor.interest = _interest;
			bor.creditRating = _creditRating;
		}
	}

	uint[] empty;
	uint[] startIndex_for_borrowers;
	// 回傳：|borrowerName&borrowerAmount,investorName&investorAmount|orrowerName&borrowerAmount,investorName&investorAmount|
	function make_a_match() public view aLive returns(string){
		string memory Info = "";
		uint[2] memory interest;
		sortedUsers(true, true); // 依照利率由高到低排序好投資方跟借錢人
		Info = checkEqualAmount(); // 比較相等的金錢的雙方
		updateCluster();
		for (uint i = 0; i<numBorrowers; i++){
			if (startIndex_for_borrowers[i] == 99) continue;
			uint startIndex = startIndex_for_borrowers[i];
			for (uint j = startIndex; j<numInvestors; j++){
				if (borrowers[i].restAmount == 0 || investors[j].restAmount == 0) break; // 若borrower的錢給完了，或是investor的錢都歸0了
				if (borrowers[i].creditRating > investors[j].creditRating) continue; // 這裡會小於是因為 int(A) < int(B)
				if (investors[j].restAmount > borrowers[i].restAmount){ // case 1：要求的利率下，investor的錢比borrower的多
					interest[0] = borrowers[i].interest;
					interest[1] = investors[j].interest;
					investors[j].restAmount -= borrowers[i].restAmount;
					borrowers[i].restAmount = 0;
					borrowers[i].interest = 0;
					Info = addInTransactionRecord(Info, i, j, interest[0], interest[1]);
				} else if (investors[j].restAmount == borrowers[i].restAmount){ // case 3：要求的利率下，investor的錢 == borrower的錢
					interest[0] = borrowers[i].interest;
					interest[1] = investors[j].interest;
					investors[j].restAmount = 0;
					investors[j].interest = 0;
					borrowers[i].restAmount = 0;
					borrowers[i].interest = 0;
					Info = addInTransactionRecord(Info, i, j, interest[0], interest[1]);
				} else { // case 3：要求的利率下，investor的錢 < borrower的錢
					interest[0] = borrowers[i].interest;
					interest[1] = investors[j].interest;
					borrowers[i].restAmount -= investors[j].restAmount;
					investors[j].restAmount = 0;
					investors[j].interest = 0;
					Info = addInTransactionRecord(Info, i, j, interest[0], interest[1]);
				}
			}
			sortedUsers(true, false); // sort investor
			updateCluster();
		}

		sortedUsers(true, true);
		// Info = concatString(Info, showAllInfo());
		return Info;
	}

	/// 確認是否已達成目標金額
	/// 此外，根據活動的成功於否進行ether的匯款
	function checkGoalReached () public{
		if (!(status == STATUS.SUCCESS || status == STATUS.FAILED)){
			if (now >= DEADLINE && status == STATUS.WAITING){
				status = STATUS.FAILED;
				FINISH_TIME = 0;
			} else if(status == STATUS.DOING_MATCH) { // 活動成功的時候
				status = STATUS.SUCCESS;
				FINISH_TIME = now;
			}
			if (!(status == STATUS.SUCCESS || status == STATUS.FAILED)) DURATION = DEADLINE - now;
			else DURATION = 0;
		}
	}

	function afterMakeAMatch(string _TRANSACTION) public {
		status = STATUS.DOING_MATCH;
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
		Info = concatString(Info, "\nNUMINVESTORS    : ");Info = concatString(Info, convertIntToString(numInvestors));
		Info = concatString(Info, "\nNUMBORROWERS    : ");Info = concatString(Info, convertIntToString(numBorrowers));
		Info = concatString(Info, "\nINVESTORS: \n");Info = concatString(Info, get_INVESTORS());
		Info = concatString(Info, "\nBORROWERS: \n");Info = concatString(Info, get_BORROWERS());
		return Info;
	}

	function get_STATUS() public view returns(string) {
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

	function get_INVESTORS() public view returns(string) {
		string memory Info = "";
		for (uint i = 0; i<numInvestors; i++){
			Info = concatString(Info, "\tname     : ");
			Info = concatString(Info, investors[i].name);Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\ttotalAmount : ");
			Info = concatString(Info, convertIntToString(investors[i].totalAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\trestAmount  : ");
			Info = concatString(Info, convertIntToString(investors[i].restAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tinterest    : ");
			Info = concatString(Info, convertIntToString(investors[i].interest));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tcreditRating  : ");
			Info = concatString(Info, convertIntToString(investors[i].creditRating));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t----------------------------------------------------------------\n");
		}
		return Info;
	}

	function get_BORROWERS() public view returns(string) {
		string memory Info = "";
		for (uint i = 0; i < numBorrowers; i++){
			Info = concatString(Info, "\tname     : ");
			Info = concatString(Info, borrowers[i].name);Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\ttotalAmount : ");
			Info = concatString(Info, convertIntToString(borrowers[i].totalAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\trestAmount  : ");
			Info = concatString(Info, convertIntToString(borrowers[i].restAmount));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tinterest    : ");
			Info = concatString(Info, convertIntToString(borrowers[i].interest));Info = concatString(Info, "\n");
			Info = concatString(Info, "\t\tcreditRating  : ");
			Info = concatString(Info, convertIntToString(borrowers[i].creditRating));Info = concatString(Info, "\n");
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

	uint[] arr;	// 要寫在外面，寫在function內會出錯==
	uint tmpPreIndex;
	uint tmpInterest;
	function sortedUsers(bool sortInvestor, bool sortBorrower) internal {
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
	function sortFromBigToSmall(uint[] data, ID _id, uint preIndex) internal returns(uint[]) {
    	if (data.length > 1) quickSort(data, int(0), int(data.length - 1), _id, preIndex);
		return data;
    }
    function quickSort(uint[] memory arr1, int left, int right, ID _id, uint preIndex) internal{
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr1[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr1[uint(i)] > pivot) i++;
            while (pivot > arr1[uint(j)]) j--;
            if (i <= j) {
                (arr1[uint(i)], arr1[uint(j)]) = (arr1[uint(j)], arr1[uint(i)]);

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
            quickSort(arr1, left, j, _id, preIndex);
        if (i < right)
            quickSort(arr1, i, right, _id, preIndex);
    }

	function checkEqualAmount() internal returns(string){
		string memory tmpTRANSACTION = "";
		uint interest0;
		uint interest1;
		for (uint i = 0; i<numBorrowers; i++){
			if (borrowers[i].restAmount == 0) break;
			for (uint j = 0; j<numInvestors; j++){
				if (investors[j].restAmount == 0) break;
				if (borrowers[i].totalAmount == investors[j].totalAmount){
					interest0 = borrowers[i].interest;
					interest1 = investors[i].interest;
					borrowers[i].restAmount = 0;
					investors[j].restAmount = 0;
					borrowers[i].interest = 0; // 為了排序的時候會跑到最後面，因此要歸0
					investors[j].interest = 0;
					tmpTRANSACTION = addInTransactionRecord(tmpTRANSACTION, i, j, interest0, interest1);
					sortedUsers(true, true);
					i--; // 因為這個borrower重新sorted跑到最後面了，所以同一個位置要從新弄
					break;
				}
			}
		}
		return tmpTRANSACTION;
	}

	function updateCluster() internal {
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

	// name totalAmount restAmount interest creditRating
	function addInTransactionRecord(string input, uint i, uint j, uint interest0, uint interest1) internal view returns(string){
		newRecord = concatString(newRecord, borrowers[i].name);newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(borrowers[i].totalAmount));newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(borrowers[i].restAmount));newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(interest0));newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(borrowers[i].creditRating));
		newRecord = concatString(newRecord, ",");
		newRecord = concatString(newRecord, investors[j].name);newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(investors[j].totalAmount));newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(investors[j].restAmount));newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(interest1));newRecord = concatString(newRecord, "&");
		newRecord = concatString(newRecord, convertIntToString(investors[j].creditRating));
		newRecord = concatString(newRecord, "|");
		return newRecord;
	}

}