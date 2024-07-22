pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);


  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:

  function buyTokens() public payable{
      require(msg.value > 0, "you need to send some eth");
      uint256 amount = msg.value;

      uint256 tokens = amount * tokensPerEth;
      uint256 tokenBalance = yourToken.balanceOf(address(this));

      require(tokenBalance >= tokens, "Not enough tokens");

      (bool sent) = yourToken.transfer(msg.sender, tokens);
      require(sent, "Failed");

      emit BuyTokens(msg.sender, amount, tokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  function withdraw() public onlyOwner{
    uint256 balance = address(this).balance;
    require(balance > 0, "no balance to withdraw");
    payable(owner()).transfer(balance);
  }

  // ToDo: create a sellTokens(uint256 _amount) function:

  function sellTokens(uint256 _amount) public {
    uint256 tokenBalance = yourToken.balanceOf(address(this));
    require(tokenBalance >= _amount, "not enough tokens");

    uint256 amount = _amount / tokensPerEth;
    require(address(this).balance >= amount, "not enough tokens");
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(sent, "Failed transfer");
    (bool sent2) = payable(msg.sender).send(amount);
    require(sent2, "Failed to send ETH");
    emit SellTokens(msg.sender, _amount, amount);
  }
}
