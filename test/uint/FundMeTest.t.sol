// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    // Prank account for testing
    uint256 constant SENT_ETH = 0.1 ether;
    uint256 constant BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 0.000001 ether;

    function setUp() external {
        // msg.sender -> FundMeTest -> FundMe
        // FundMe.owner is FundMeTest, not msg.sender
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, BALANCE);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAggregatorV3InterfaceVersionIsFour() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    modifier prankFunded() {
        vm.prank(USER); // the next TX is sent by USER
        fundMe.fund{value: SENT_ETH}();
        _;
    }

    function testFundIsNotEnoughEth() public prankFunded {
        vm.expectRevert(); // the next TX should revert
        fundMe.fund(); // send 0 ETH
    }

    function testUpdateAddressToAmountFunded() public prankFunded {
        uint256 fundedAmount_ = fundMe.getAddressToAmountFunded(USER);
        assertEq(fundedAmount_, SENT_ETH);
    }

    function testAddFunderToFunders() public prankFunded {
        address fundedAddress_ = fundMe.getFunders(0);
        assertEq(fundedAddress_, USER);
    }

    function testOnlyOwnerCanWithdraw() public prankFunded {
        vm.expectRevert(); // the next TX should revert
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testSuccessfulWithdrawByOwner() public prankFunded {
        //Arange
        //write down the balance after prankFunded
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startContractBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner()); //simulate the contract owner
        fundMe.withdraw();

        //Assert
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endContractBalance = address(fundMe).balance;
        assertEq(endContractBalance, 0);
        assertEq(endOwnerBalance, startOwnerBalance + startContractBalance);
    }

    function testSuccessfulWithdrawByOwnerAfterSeveralFunding()
        public
        prankFunded
    {
        //Arange
        uint160 numOfFunders = 10; //Address is uint160
        uint160 startIndex = 1; //don't use 0 if generate temp address for testing
        for (uint160 i = startIndex; i < numOfFunders; i++) {
            hoax(address(i), BALANCE);
            fundMe.fund{value: SENT_ETH}();
        }

        //write down the balance after multiple fundings
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startContractBalance = address(fundMe).balance;

        //Act
        // uint256 gastStart = gasleft();
        // vm.txGasPrice(GAS_PRICE); //simulate gas price > 0, 0 is default on anvil
        vm.startPrank(fundMe.getOwner()); //simulate the contract owner
        fundMe.withdraw();
        vm.stopPrank();
        // uint256 gastEnd = gasleft();
        // uint256 gasUsed = (gastEnd - gastStart) * tx.gasprice;
        // console.log(gasUsed);

        //Assert
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endContractBalance = address(fundMe).balance;
        assertEq(endContractBalance, 0);
        assertEq(endOwnerBalance, startOwnerBalance + startContractBalance);
    }

    function testSuccessfulCheapWithdrawByOwnerAfterSeveralFunding()
        public
        prankFunded
    {
        //Arange
        uint160 numOfFunders = 10; //Address is uint160
        uint160 startIndex = 1; //don't use 0 if generate temp address for testing
        for (uint160 i = startIndex; i < numOfFunders; i++) {
            hoax(address(i), BALANCE);
            fundMe.fund{value: SENT_ETH}();
        }

        //write down the balance after multiple fundings
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startContractBalance = address(fundMe).balance;

        //Act
        // uint256 gastStart = gasleft();
        // vm.txGasPrice(GAS_PRICE); //simulate gas price > 0, 0 is default on anvil
        vm.startPrank(fundMe.getOwner()); //simulate the contract owner
        fundMe.cheapWithdraw();
        vm.stopPrank();
        // uint256 gastEnd = gasleft();
        // uint256 gasUsed = (gastEnd - gastStart) * tx.gasprice;
        // console.log(gasUsed);

        //Assert
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endContractBalance = address(fundMe).balance;
        assertEq(endContractBalance, 0);
        assertEq(endOwnerBalance, startOwnerBalance + startContractBalance);
    }
}
