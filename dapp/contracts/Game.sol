pragma solidity ^0.5.0;

interface Game{ 

	//General interface game functions
	function isBetSet() external view returns(bool);
	function bet(string calldata empty, uint8 playerBet) external payable returns(uint8, bool, uint256);
	function cancelBet() external returns(uint256);
	function play() external returns(uint8 , uint8);
	function playerMoneyWin() external returns(uint256);

}