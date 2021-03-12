pragma solidity ^0.5.0;

interface Game{ 



	//General interface game functions
	function isBetSet() external view returns(bool);
	function bet(string calldata empty, uint playerBet) external payable returns(uint, bool, uint);
	function cancelBet() external returns(uint);
	function play() external returns(uint , uint);
	function playerReceivesMoney() external returns(uint);
	


}