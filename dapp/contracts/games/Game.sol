pragma solidity ^0.5.0;

//game interface
interface Game{ 

    //returns if the user has a current bet
    function isBetSet(address player) external view returns(bool); //onlyOwner
    //returns if the bet has been set
    function bet(address player, string calldata betInfo, uint8 betData, uint256 money) external returns(bool); //onlyOwner
    //returns the amount of money of the canceled bet (0 if no bet)
    function cancelBet(address player) external returns(uint256); //onlyOwner
    //returns the result and the amout of money the player has won
    //the current bet is then deleted 
    function play(address player) external returns(uint8 , uint256); //onlyOwner
	// function playerMoneyWin() external returns(uint256);

}
