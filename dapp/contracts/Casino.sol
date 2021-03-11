pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Casino is Ownable{ //Ownable allows use onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	uint randomId = 0;
	uint public gameType = 0; //0: null, 1: dice, 2: roulette
	uint public maximumBetValue = 1 ether;
	uint public minimumBetValue = 0.001 ether;
	uint private contractBalance = 0;



	//Events
	event EventCancelBet(address player);



	//Modifiers
	modifier isEnoughMoney(){
		require(msg.value >= minimumBetValue, "Too low bet value");
		require(msg.value <= maximumBetValue, "Too high bet value");
		_;
	}
	modifier currentBetIsNotSet(){
		require(betsMap[currentPlayer].isSet == false, "There is already a bet ready");
		_;
	}
	modifier currentBetIsSet(){
		require(betsMap[currentPlayer].isSet == true, "You need to bet before playing"); 
		_;
	}



	//General abstract casino functions
	function playerReceivesMoney() external{
		if(gameType == 1){ //1: dice
			//msg.sender.transfer(betsMap[currentPlayer].moneyBet * diceBetMultiplier);
		}else if(gameType == 2){ //2: roulette
			//msg.sender.transfer(betsMap[currentPlayer].moneyBet * betsMap[currentPlayer].rouletteBetMultiplier);
		}
	}
	function bet() external{

	}
	function play() external{

	}
	function cancelBet() external returns(bool){
		require(betsMap[currentPlayer].isSet == true, "There is no bet currently");
		betsMap[currentPlayer].diceBet = 0;
		betsMap[currentPlayer].rouletteBet = "";
		betsMap[currentPlayer].isSet = false;
		betsMap[currentPlayer].diceResult = 0;
		msg.sender.transfer(betsMap[currentPlayer].moneyBet);
		betsMap[currentPlayer].moneyBet = 0;
		emit EventCancelBet(currentPlayer);
		return true;
	}
	function setGameType(uint type) external{
		gameType = type;
	}
	function isBetSet() public view returns(bool){
		return betsMap[currentPlayer].isSet;
	}



    //Admin functions with onlyOwner
    function addFundsContractBalance() external payable onlyOwner{
    	require(msg.value > 0, "No funds transfered");
		contractBalance += msg.value;
	}
    function withdrawContractBalance() external onlyOwner{
		msg.sender.transfer(contractBalance);
	}
	function getContractBalance() external view onlyOwner returns(uint){
		return contractBalance;
	}



	//Utility functions
	function randomUintBetween(uint min, uint max) private returns(uint){
		randomId++;
		return uint(keccak256(abi.encodePacked(now, msg.sender, randomId))) % max + min;
	}
	function stringToUint(string memory s) internal pure returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i])); //Conversion trick
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {
        uint number = _i;
        if (number == 0) {
            return "0";
        }
        uint j = number;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (number != 0) {
            bstr[k--] = byte(uint8(48 + number % 10));
            number /= 10;
        }
        return string(bstr);
    }
    function compareStrings(string memory a, string memory b) internal pure returns(bool){
    	return keccak256(bytes(a)) == keccak256(bytes(b));
    }
	


}