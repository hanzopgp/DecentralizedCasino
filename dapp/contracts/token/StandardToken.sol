pragma solidity ^0.5.0;

import "./ERC721.sol";

contract StandardToken is ERC721{

    uint256 public totalSupply;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function transfer(address to, uint256 value) public returns(bool success){
        if (balances[msg.sender] >= value && value > 0){
            balances[msg.sender] -= value;
            balances[to] += value;
            emit Transfer(msg.sender, to, value);
            return true;
        } else { 
            return false; 
        }
    }

    function transferFrom(address from, address to, uint256 value) public returns(bool success){
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0){
            balances[to] += value;
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
            emit Transfer(from, to, value);
            return true;
        } else { 
            return false; 
        }
    }

    function balanceOf(address owner) external view returns(uint256 balance){
        return balances[owner];
    }

    function approve(address spender, uint256 value) external payable returns(bool success){
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns(uint256 remaining){
      return allowed[owner][spender];
    }

}