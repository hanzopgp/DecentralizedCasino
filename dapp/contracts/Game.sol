pragma solidity ^0.5.0;

abstract contract Game{ 



	//Variables
	uint public maximumBetValue = 1 ether;
	uint public minimumBetValue = 0.001 ether;



	//Events
	event EventBet(address player , uint diceBet);
	event EventResult(address player, uint diceBet , uint diceResult);



	//Modifiers
	modifier isEnoughMoney(){
		require(msg.value >= minimumBetValue, "Too low bet value");
		require(msg.value <= maximumBetValue, "Too high bet value");
		_;
	}
	modifier currentBetIsNotSet(){
		require(betsMap[msg.sender].isSet == false, "There is already a bet ready");
		_;
	}
	modifier currentBetIsSet(){
		require(betsMap[msg.sender].isSet == true, "You need to bet before playing"); 
		_;
	}



	//General abstract game functions
	function isBetSet() public view returns(bool);
	function bet(string empty, uint playerBet) public payable isEnoughMoney currentBetIsNotSet returns(uint, bool, uint);
	function cancelBet() currentBetIsSet external returns(bool);
	function play() public currentBetIsSet returns(address , uint , uint);
	function playerReceivesMoney() external;
	


}