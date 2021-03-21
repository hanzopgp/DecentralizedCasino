pragma solidity ^0.5.0;

import "./ERC721.sol";
import "./../lib/SafeMath.sol";
import "./../Casino.sol";

contract Casitoken is Casino, ERC721{

  using SafeMath for uint256;

  mapping (uint => address) approvals;

  modifier onlyOwnerOf(uint tokenId) {
    require(msg.sender == tokensToOwner[tokenId]);
    _;
  }

  function balanceOf(address owner) external view returns(uint256){
    return tokensMap[owner];
  }

  function ownerOf(uint256 tokenId) external view returns(address){
    return tokensToOwner[tokenId];
  }

  function transfer(address from, address to, uint256 tokenId) public returns(bool success){
    tokensMap[to] = tokensMap[to].add(1);
    tokensMap[msg.sender] = tokensMap[msg.sender].sub(1);
    tokensToOwner[tokenId] = to;
    emit Transfer(from, to, tokenId);
    return true;
  }

  function transferFrom(address from, address to, uint256 tokenId) external payable returns(bool success){
    require (tokensToOwner[tokenId] == msg.sender || approvals[tokenId] == msg.sender);
    transfer(from, to, tokenId);
    return true;
  }

  function approve(address approved, uint256 tokenId) external payable onlyOwnerOf(tokenId) returns(bool success){
    approvals[tokenId] = approved;
    emit Approval(msg.sender, approved, tokenId);
    return true;
  }

}