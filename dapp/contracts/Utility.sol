pragma solidity ^0.5.0;

import "./lib/SafeMath.sol";

contract Utility{

    using SafeMath for uint256; //Using SafeMath lib to avoid overflow errors
    using SafeMath for uint8;

    //Variables
    uint256 randomId = 0;
    uint16 public maximumTokenValue = 1000;
    uint16 public minimumTokenValue = 1;

    //Modifiers
    modifier isEnoughMoneyAndToken(uint value, uint nbtoken, uint tokenPrice){
        require(value >= minimumTokenValue*tokenPrice, "Too low bet value");
        require(value <= maximumTokenValue*tokenPrice, "Too high bet value");
        require(nbtoken >= minimumTokenValue, "Too low token value");
        require(nbtoken <= maximumTokenValue, "Too high token value");
        _;
    }

    modifier enoughTokenBalance(uint tokenamount, uint tokenbalance){
        require(tokenbalance >= tokenamount, "Not enough token in balance");
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
		randomId = randomId.add(1);
		return uint8((uint(keccak256(abi.encodePacked(now, msg.sender, randomId))) % max ).add(min));
	}

    function compareStrings(string memory a, string memory b) internal pure returns(bool){
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

	function stringToUint(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint i = 0; i < b.length; i = i.add(1)) {
            uint c = uint(uint8(b[i])); //Conversion trick
            if (c >= 48 && c <= 57) {
                result = result.mul(10 + c - 48);
            }
        }
    }

    function uintToString(uint _i) internal pure returns (string memory) {
        uint256 number = _i;
        if (number == 0) {
            return "0";
        }
        uint256 j = number;
        uint256 len;
        while (j != 0) {
            len = len.add(1);
            j = j.div(10);
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len.sub(1);
        while (number != 0) {
            bstr[k = k.sub(1)] = byte(uint8(48 + number % 10));
            number = number.div(10);
        }
        return string(bstr);
    }



}
