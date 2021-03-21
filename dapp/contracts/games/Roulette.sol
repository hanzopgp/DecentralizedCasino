pragma solidity ^0.5.0;

import "./../lib/SafeMath.sol";
import "./../lib/Ownable.sol";
import "./Game.sol";
import "./../Utility.sol";

contract Roulette is Game, Utility, Ownable {

    using SafeMath for uint256; //Using SafeMath lib to avoid overflow errors
    using SafeMath for uint8;

    /* For details on types of bet of the roulette game,
    see https://en.wikipedia.org/wiki/Roulette#Types_of_bets */
    struct RouletteBet {
        // bool isSet;
        uint256 money;
        uint8 numberOfCard;
        /* 1-Single ; 2-Split ; 3-Street ; 4:Square ; 6-DoubleStreet ; 12-Column/Dozen ;
        18-Low/High/Red/Black/Even/Odd ; 24-DoubleColumn/DoubleDozen */
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

    // reds = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    // blacks = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35];
    bool[36] private isNumberRed =
        [true, false, true, false, true, false, true, false, true, false,
        false, true, false, true, false, true, false, true, true, false,
        true, false, true, false, true, false, true, false, false, true,
        false, true, false, true, false, true];

    function isBetSet(address player) external view onlyOwner returns(bool){
        return _playersBet[player].numberOfCard != 0;
    }

    function bet(address player, string calldata _typeOfCard, uint8 _dataOfBet, uint256 money) external onlyOwner isEnoughMoney(money) currentBetIsNotSet(_playersBet[player].numberOfCard != 0) returns(bool) {
        uint numberOfCard = 0;
        uint betData = 0;
        if(compareStrings(_typeOfCard, "Single")){
            if(0 <= _dataOfBet && _dataOfBet <= 36){
                numberOfCard = 1;
                betData = _dataOfBet;
            }
        }else if(compareStrings(_typeOfCard, "Horizontal split")){
            if(1 <= _dataOfBet && _dataOfBet <= 35 && _dataOfBet % 3 != 0){
                numberOfCard = 2;
                betData = 2*((_dataOfBet-1)/3) + ((_dataOfBet-1)%3);
            }
        }else if(compareStrings(_typeOfCard, "Vertical split")){
            if(1 <= _dataOfBet && _dataOfBet <= 33){
                numberOfCard = 2;
                betData = 23 + _dataOfBet;
            }
        }else if(compareStrings(_typeOfCard, "Street")){
            if(1 <= _dataOfBet && _dataOfBet <= 12){
                numberOfCard = 3;
                betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfCard, "Square")){
            if(1 <= _dataOfBet && _dataOfBet <= 32 && _dataOfBet % 3 != 0){
                numberOfCard = 4;
                betData = 2*((_dataOfBet-1)/3) + ((_dataOfBet-1)%3);
            }
        }else if(compareStrings(_typeOfCard, "Double street")){
            if(1 <= _dataOfBet && _dataOfBet <= 11){
                numberOfCard = 6;
                betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfCard, "Column")){
            if(1 <= _dataOfBet && _dataOfBet <= 3){
                numberOfCard = 12;
                betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfCard, "Dozen")){
            if(1 <= _dataOfBet && _dataOfBet <= 3){
                numberOfCard = 12;
                betData = 2 + _dataOfBet;
            }
        }else if(compareStrings(_typeOfCard, "Low")){
            numberOfCard = 18;
            betData = 0;
        }else if(compareStrings(_typeOfCard, "High")){
            numberOfCard = 18;
            betData = 1;
        }else if(compareStrings(_typeOfCard, "Red")){
            numberOfCard = 18;
            betData = 2;
        }else if(compareStrings(_typeOfCard, "Black")){
            numberOfCard = 18;
            betData = 3;
        }else if(compareStrings(_typeOfCard, "Even")){
            numberOfCard = 18;
            betData = 4;
        }else if(compareStrings(_typeOfCard, "Odd")){
            numberOfCard = 18;
            betData = 5;
        }else if(compareStrings(_typeOfCard, "Double column")){
            if(1 <= _dataOfBet && _dataOfBet <= 2){
                numberOfCard = 24;
                betData = _dataOfBet-1;
            }
        }else if(compareStrings(_typeOfCard, "Double dozen")){
            if(1 <= _dataOfBet && _dataOfBet <= 2){
                numberOfCard = 24;
                betData = 1 + _dataOfBet;
            }
        }
        bool _isValid = (numberOfCard != 0);
        require(_isValid, "Invalid type of bet");
        _playersBet[player].money = money;
        _playersBet[player].numberOfCard = uint8(numberOfCard);
        _playersBet[player].betData = uint8(betData);
        return _isValid;
    }

    function cancelBet(address player) external onlyOwner currentBetIsSet(_playersBet[player].numberOfCard != 0) returns(uint256){
        _playersBet[player].numberOfCard = 0;
        return _playersBet[player].money;
    }

    function play(address player) external onlyOwner currentBetIsSet(_playersBet[player].numberOfCard != 0) returns (uint8, uint256) {
        uint8 _result = randomUintBetween(0, 36);
        bool _hasWon = false;
        RouletteBet memory _bet = _playersBet[player];
        if(_bet.numberOfCard == 1){
            if(_result == _bet.betData){
                _hasWon = true;
            }
        }else if(_bet.numberOfCard == 2){
            if(_bet.betData <= 23){
                uint8 _leftNumber = 3*(_bet.betData/2) + (_bet.betData%2) + 1;
                if(_result == _leftNumber || _result == _leftNumber+1){
                    _hasWon = true;
                }
            }else{
                uint8 _upperNumber = _bet.betData - 23;
                if(_result == _upperNumber || _result == _upperNumber+3){
                    _hasWon = true;
                }
            }
        }else if(_bet.numberOfCard == 3){
            uint8 _leftNumber = 3*_bet.betData + 1;
            if(_leftNumber <= _result && _result <= _leftNumber+1
                || _result == _leftNumber+2){
                _hasWon = true;
            }
        }else if(_bet.numberOfCard == 4){
            uint8 _leftUpperNumber = 3*(_bet.betData/2) + (_bet.betData%2) + 1;
            if(_result == _leftUpperNumber || _result == _leftUpperNumber+1
                || _result == _leftUpperNumber+3 || _result == _leftUpperNumber+4){
                _hasWon = true;
            }
        }else if(_bet.numberOfCard == 6){
            uint8 _leftUpperNumber = 3*(_bet.betData/2) + (_bet.betData%2) + 1;
            if(_leftUpperNumber <= _result && _result <= _leftUpperNumber+6){
                _hasWon = true;
            }
        }else if(_bet.numberOfCard == 12){
            if(_bet.betData <= 2){
                if((_result-1) % 3 == _bet.betData){
                    _hasWon = true;
                }
            }else{
                if((_bet.betData-3)*12 + 1 <= _result && _result <= (_bet.betData-2)*12){
                    _hasWon = true;
                }
            }
        }else if(_bet.numberOfCard == 18){
            if(_bet.betData == 0){
                if(1 <= _result && _result <= 18){
                    _hasWon = true;
                }
            }else if(_bet.betData == 1){
                if(19 <= _result && _result <= 36){
                    _hasWon = true;
                }
            }else if(_bet.betData == 2){
                if(_result != 0 && isNumberRed[_result-1]){
                    _hasWon = true;
                }
            }else if(_bet.betData == 3){
                if(_result != 0 && !isNumberRed[_result-1]){
                    _hasWon = true;
                }
            }else if(_bet.betData == 4){
                if(_result % 2 == 0){
                    _hasWon = true;
                }
            }else if(_bet.betData == 5){
                if(_result % 2 == 1){
                    _hasWon = true;
                }
            }
        }else if(_bet.numberOfCard == 24){
            if(_bet.betData <= 1){
                uint8 _remainder = (_result-1) % 3;
                if(_remainder == _bet.betData || _remainder == _bet.betData+1){
                    _hasWon = true;
                }
            }else{
                if((_bet.betData-1)*12 + 1 <= _result && _result <= (_bet.betData+1)*12){
                    _hasWon = true;
                }
            }
        }
        _playersBet[player].numberOfCard = 0;
        if(_hasWon){
            uint _moneyWon = _bet.money * (36/_bet.numberOfCard);
            _moneyWon += ((36 % _bet.numberOfCard) * _bet.money) / _bet.numberOfCard;
            return (_result, _moneyWon);
        }
        return (_result, 0);
    }

}
