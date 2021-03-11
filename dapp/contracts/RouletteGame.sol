pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract RouletteGame is Ownable {

    using SafeMath for uint256;

    /* For details on types of bet of the roulette game,
    see https://en.wikipedia.org/wiki/Roulette#Types_of_bets */
    struct RouletteBet {
        uint money;
        uint8 typeOfBet;
        /* 1-Single ; 2-Split ; 3-Street ; 4:Square ; 5-DoubleStreet ; 6-Column/Dozen ;
        7-Low/High/Red/Black/Even/Odd ; 8-DoubleColumn/DoubleDozen */
        uint8 betData;
        /*
        Single                      -> number with the bet (0 <= n <= 36)
        Split                       -> 0 to 23, horizontal split : left number = 3*(n//2)+n%2+1,
                                                                    right number = left number + 1
                                        24+0 to 24+32, vertical split : upper number = n-23,
                                                                        down number = upper number + 3
        Street                      -> number of the line with the bet (0 <= n <= 11)
        Square                      -> 0 to 21, number of the upper left number = 3*(n//2)+n%2+1
        DoubleStreet                -> number of the upper line with the bet (0 <= n <= 10)
        Column/Dozen                -> 0 to 2, column (number of the column)
                                        3+0 to 3+2, dozen (3 : 1-12, 4 : 13-24, 5 : 25-36)
        Low/High/Red/Black/Even/Odd -> respectively 0/1/2/3/4/5
        DoubleColummn/DoubleDozen   -> 0 to 1, double column (number of the left column)
                                        2+0 to 2+1, double dozen (2 : 1-24, 3 : 13-36)
        */
    }

    mapping(address => RouletteBet) private _playersBet;

    uint8[18] private reds = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    uint8[18] private blacks = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35];

    event EventRouletteBet(address player , RouletteBet bet);
    event EventRouletteResult(address player, uint drawnNumber);

    function bet(string calldata _typeOfBet, uint _dataOfBet) external payable {
        RouletteBet _newBet = RouletteBet(msg.value, 0, 0);
        if(compareStrings(_typeOfBet, "Single")){
            if(0 <= _dataOfBet && _dataOfBet <= 36){
                _newBet.typeOfBet = 1;
                _newBet.betData = _dataOfBet;
            }
        }else if(compareStrings(_typeOfBet, "Horizontal split")){
            if(1 <= _dataOfBet && _dataOfBet <= 35 && _dataOfBet % 3 != 0){
                _newBet.typeOfBet = 2;
                _newBet.betData = 2*((_dataOfBet-1)/3) + ((_dataOfBet-1)%3);
            }
        }else if(compareStrings(_typeOfBet, "Vertical split")){
            if(1 <= _dataOfBet && _dataOfBet <= 33){
                _newBet.typeOfBet = 2;
                _newBet.betData = 23 + _dataOfBet;
            }
        }else if(compareStrings(_typeOfBet, "Street")){
            if(1 <= _dataOfBet && _dataOfBet <= 12){
                _newBet.typeOfBet = 3;
                _newBet.betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfBet, "Square")){
            if(1 <= _dataOfBet && _dataOfBet <= 32 && _dataOfBet % 3 != 0){
                _newBet.typeOfBet = 4;
                _newBet.betData = 2*((_dataOfBet-1)/3) + ((_dataOfBet-1)%3);
            }
        }else if(compareStrings(_typeOfBet, "Double street")){
            if(1 <= _dataOfBet && _dataOfBet <= 11){
                _newBet.typeOfBet = 5;
                _newBet.betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfBet, "Column")){
            if(1 <= _dataOfBet && _dataOfBet <= 3){
                _newBet.typeOfBet = 6;
                _newBet.betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfBet, "Dozen")){
            if(1 <= _dataOfBet && _dataOfBet <= 3){
                _newBet.typeOfBet = 6;
                _newBet.betData = 2 + _dataOfBet;
            }
        }else if(compareStrings(_typeOfBet, "Low")){
            _newBet.typeOfBet = 7;
            _newBet.betData = 0;
        }else if(compareStrings(_typeOfBet, "High")){
            _newBet.typeOfBet = 7;
            _newBet.betData = 1;
        }else if(compareStrings(_typeOfBet, "Red")){
            _newBet.typeOfBet = 7;
            _newBet.betData = 2;
        }else if(compareStrings(_typeOfBet, "Black")){
            _newBet.typeOfBet = 7;
            _newBet.betData = 3;
        }else if(compareStrings(_typeOfBet, "Even")){
            _newBet.typeOfBet = 7;
            _newBet.betData = 4;
        }else if(compareStrings(_typeOfBet, "Odd")){
            _newBet.typeOfBet = 7;
            _newBet.betData = 5;
        }else if(compareStrings(_typeOfBet, "Double column")){
            if(1 <= _dataOfBet && _dataOfBet <= 2){
                _newBet.typeOfBet = 8;
                _newBet.betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfBet, "Double dozen")){
            if(1 <= _dataOfBet && _dataOfBet <= 2){
                _newBet.typeOfBet = 3;
                _newBet.betData = 1 + _dataOfBet;
            }
        }
        if(_newBet.typeOfBet == 0){ // wrong input, sending ethers back
            msg.sender.transfer(msg.value);
        }else{
            _playersBet[msg.sender] = _newBet;
        }
    }

    function play() external returns (uint) {
        uint _result = randomUintBetween(0, 36);
        uint _winRate = 0;
        RouletteBet _bet = _playersBet[msg.sender];
        if(_bet.typeOfBet == 1){
            if(_result == _bet.betData){
                _winRate = 36;
            }
        }else if(_bet.typeOfBet == 2){
            if(_bet.betData <= 23){
                uint _leftNumber = 3*(_bet.betData/2) + (_bet.betData%2) + 1;
                if(_result == _leftNumber || _result == _leftNumber+1){
                    _winRate = 18;
                }
            }else{
                uint _upperNumber = _bet.betData - 23;
                if(_result == _upperNumber || _result == _upperNumber+3){
                    _winRate = 18;
                }
            }
        }else if(_bet.typeOfBet == 3){
            uint _leftNumber = 3*_bet.betData + 1;
            if(_leftNumber <= _result == _leftNumber+1
                || _result == _leftNumber+2){
                _winRate = 12;
            }
        }else if(_bet.typeOfBet == 4){
            uint _leftUpperNumber = 3*(_bet.betData/2) + (_bet.betData%2) + 1;
            if(_result == _leftUpperNumber || _result == _leftUpperNumber+1
                || _result == _leftUpperNumber+3 || _result == _leftUpperNumber+4){
                _winRate = 9;
            }
        }else if(_bet.typeOfBet == 5){
            if()
        }

    }
}
