pragma solidity ^0.5.0;

contract ERC721{

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external view returns (uint256 supply);
    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address to, uint256 value) public returns (bool success);
    function transferFrom(address from, address to, uint256 value) external payable returns (bool success);
    function approve(address spender, uint256 value) external payable returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining); 
    
}