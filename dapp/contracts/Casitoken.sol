pragma solidity ^0.5.0;

import "./Casino.sol";
import "./lib/ERC721.sol";
import "./lib/SafeMath.sol";

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

  function transfer(address from, address to, uint256 tokenId) private{
    tokensMap[to] = tokensMap[to].add(1);
    tokensMap[msg.sender] = tokensMap[msg.sender].sub(1);
    tokensToOwner[tokenId] = to;
    emit Transfer(from, to, tokenId);
  }

  function transferFrom(address from, address to, uint256 tokenId) external payable{
    require (tokensToOwner[tokenId] == msg.sender || approvals[tokenId] == msg.sender);
    transfer(from, to, tokenId);
  }

  function approve(address approved, uint256 tokenId) external payable onlyOwnerOf(tokenId){
    approvals[tokenId] = approved;
    emit Approval(msg.sender, approved, tokenId);
  }

}