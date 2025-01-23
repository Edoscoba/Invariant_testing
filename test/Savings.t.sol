// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Savings} from "../src/Savings.sol";
import {ERC20Token} from "../src/Token.sol";

contract SavingsInvariants is StdInvariant, Test {
    Savings public savings;
    ERC20Token public token;
    address public constant ALICE = address(0x1);
    address public constant BOB = address(0x2);

    function setUp() public {
        token = new ERC20Token();
        savings = new Savings(address(token));
        
        token.transfer(ALICE, 100_000e18);
        token.transfer(BOB, 100_000e18);

        vm.startPrank(ALICE);
        token.approve(address(savings), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(BOB);
        token.approve(address(savings), type(uint256).max);
        vm.stopPrank();

        targetContract(address(savings));
    }

    function invariant_totalDepositedMatchesBalances() public {
        uint256 totalBalances = savings.balances(ALICE) + savings.balances(BOB);
        assertEq(savings.totalDeposited(), totalBalances, "Total deposited should match sum of balances");
    }

    function invariant_depositLimits() public {
        assertTrue(savings.totalDeposited() <= savings.MAX_DEPOSIT_AMOUNT(), "Total deposited should not exceed MAX_DEPOSIT_AMOUNT");
        assertTrue(savings.balances(ALICE) >= savings.MIN_DEPOSIT_AMOUNT() || savings.balances(ALICE) == 0, "Individual balance should be at least MIN_DEPOSIT_AMOUNT or zero");
        assertTrue(savings.balances(BOB) >= savings.MIN_DEPOSIT_AMOUNT() || savings.balances(BOB) == 0, "Individual balance should be at least MIN_DEPOSIT_AMOUNT or zero");
    }

    function invariant_contractBalanceMatchesTotalDeposited() public {
        assertEq(token.balanceOf(address(savings)), savings.totalDeposited(), "Contract token balance should match totalDeposited");
    }

    function invariant_userBalancesNotExceedTotalSupply() public {
        assertTrue(savings.balances(ALICE) <= token.totalSupply(), "User balance should not exceed total supply");
        assertTrue(savings.balances(BOB) <= token.totalSupply(), "User balance should not exceed total supply");
    }

    function invariant_timestampsAreSetOrZero() public {
        assertTrue(savings.timestamps(ALICE) == 0 || savings.timestamps(ALICE) <= block.timestamp, "Timestamp should be 0 or less than or equal to current timestamp");
        assertTrue(savings.timestamps(BOB) == 0 || savings.timestamps(BOB) <= block.timestamp, "Timestamp should be 0 or less than or equal to current timestamp");
    }

    function invariant_totalDepositedNotExceedTotalSupply() public {
        assertTrue(savings.totalDeposited() <= token.totalSupply(), "Total deposited should not exceed total token supply");
    }
}