pragma solidity ^0.5.0;

import "./SafeMath.sol";

contract Utility{



    //Variables
    uint256 randomId = 0;
    uint256 public maximumBetValue = 10 ether;
    uint256 public minimumBetValue = 0 ether;



    //Modifiers
    modifier isEnoughMoney(){
        require(msg.value >= minimumBetValue, "Too low bet value");
        require(msg.value <= maximumBetValue, "Too high bet value");
        _;
    }
    modifier currentBetIsNotSet(bool betIsSet){
        require(betIsSet == false, "There is already a bet ready");
        _;
    }
    modifier currentBetIsSet(bool betIsSet){
        require(betIsSet == true, "You need to bet before playing"); 
        _;
    }



    //Utility functions
	function randomUintBetween(uint8 min, uint8 max) internal returns(uint8){
		randomId++;
		return uint8(uint(keccak256(abi.encodePacked(now, msg.sender, randomId))) % max + min);
	}
    function compareStrings(string memory a, string memory b) internal pure returns(bool){
        return keccak256(bytes(a)) == keccak256(bytes(b));
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
        uint256 number = _i;
        if (number == 0) {
            return "0";
        }
        uint256 j = number;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (number != 0) {
            bstr[k--] = byte(uint8(48 + number % 10));
            number /= 10;
        }
        return string(bstr);
    }



}