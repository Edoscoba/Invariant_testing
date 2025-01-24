// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Savings.sol";
import "../src/Token.sol";

contract SavingsTest is Test {
    Savings savings;
    ERC20Token token;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        token = new ERC20Token();
        savings = new Savings(address(token));
        token.transfer(user1, 100e18);
        token.transfer(user2, 100e18);
    }

    function testDeposit() public {
        vm.startPrank(user1);
        token.approve(address(savings), 50e18);
        savings.deposit(50e18);
        assertEq(savings.balances(user1), 50e18);
        assertEq(savings.totalDeposited(), 50e18);
        vm.stopPrank();
    }  

    function testWithdraw() public {
        vm.startPrank(user1);
        token.approve(address(savings), 50e18);
        savings.deposit(50e18);
        savings.withdraw(20e18, user1);
        assertEq(savings.balances(user1), 30e18);
        assertEq(savings.totalDeposited(), 30e18);
        vm.stopPrank();
    }

    function testGetInterestPerAnnum() public {
        vm.startPrank(user1);
        token.approve(address(savings), 50e18);
        savings.deposit(50e18);
        vm.warp(block.timestamp + 365 days);
        savings.getInterestPerAnnum();
        assertEq(token.balanceOf(user1), 55e18); // 50e18 deposit + 5e18 interest
        vm.stopPrank();
    }

    function invariantTotalDeposited() public {
        uint256 total = 0;
        total += savings.balances(user1);
        total += savings.balances(user2);
        assertEq(total, savings.totalDeposited());
    }
}