pragma solidity ^0.5.0;

import "./SafeMath.sol";

contract Utility{



    //Variables
    uint randomId = 0;
    uint public maximumBetValue = 10 ether;
    uint public minimumBetValue = 0 ether;



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
	function randomUintBetween(uint min, uint max) internal returns(uint){
		randomId++;
		return uint(keccak256(abi.encodePacked(now, msg.sender, randomId))) % max + min;
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



}