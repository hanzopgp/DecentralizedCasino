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
	Game game;



	//Game type setter
	function setGameType(uint type) external{
		gameType = type;
		if(type = 1){
			game = new Dice(msg.sender);
		}
		else if(type == 2){
			game = new Roulette(msg.sender);
		}	
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