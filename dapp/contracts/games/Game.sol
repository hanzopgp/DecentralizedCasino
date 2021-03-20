pragma solidity ^0.5.0;

//game interface
interface Game{ 

    //returns true if the user has set his bet
    function isBetSet(address player) external view returns(bool);

    //returns the bet which has been set
    function bet(address player, string calldata betInfo, uint8 betData, uint256 money) external returns(bool);

    //returns the amount of the canceled bet (0 if no bet)
    function cancelBet(address player) external returns(uint256);

    //returns the result and the amount of money the player has won, the current bet is then deleted 
    function play(address player) external returns(uint8 , uint256);

}
