// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20,  Ownable(msg.sender) {
    uint256 public constant INITIAL_SUPPLY = 1_000_000e18; // 1,000,000 tokens with 18 decimals

    constructor() ERC20("Savings Token", "SVT") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // Function to mint new tokens, only callable by the owner
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Function to burn tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Function to allow the Savings contract to mint interest tokens
    function mintInterest(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        _mint(to, amount);
    }
}