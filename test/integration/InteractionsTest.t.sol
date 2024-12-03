// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFromFundMe, WithdrawFromFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    // address USER = makeAddr("user");

    // // Prank account for testing
    // uint256 constant SENT_ETH = 0.1 ether;
    // uint256 constant BALANCE = 10 ether;
    // uint256 constant GAS_PRICE = 0.000001 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // vm.deal(USER, BALANCE);
    }

    function testUserCanFundThenWithdraw() public {
        uint256 initOwnerBalance = fundMe.getOwner().balance;
        uint256 initContractBalance = address(fundMe).balance;
        console.log(
            "initOwnerBalance: %s | initContractBalance: %s",
            initOwnerBalance,
            initContractBalance
        );

        // execute fund function
        FundFromFundMe fundFromFundMe = new FundFromFundMe();
        fundFromFundMe.fundFromFundMe(address(fundMe));
        // write down the balance after funding
        uint256 fundedOwnerBalance = fundMe.getOwner().balance;
        uint256 fundedContractBalance = address(fundMe).balance;

        console.log(
            "fundedOwnerBalance: %s | fundedContractBalance: %s",
            fundedOwnerBalance,
            fundedContractBalance
        );

        // execute withdraw function
        WithdrawFromFundMe withdrawFromFundMe = new WithdrawFromFundMe();
        withdrawFromFundMe.withdrawFromFundMe(address(fundMe));
        // write down the balance after withdrawl
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endContractBalance = address(fundMe).balance;

        console.log(
            "endOwnerBalance: %s | endContractBalance: %s",
            endOwnerBalance,
            endContractBalance
        );

        assertEq(endContractBalance, 0);
        assertEq(endOwnerBalance, fundedOwnerBalance + fundedContractBalance);
    }
}
