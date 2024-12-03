// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFromFundMe is Script {
    uint256 constant SEND_ETH = 0.01 ether;

    function fundFromFundMe(address _latestDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_latestDeployed)).fund{value: SEND_ETH}();
        vm.stopBroadcast();
        console.log("Funding %s", SEND_ETH);
    }

    function run() external {
        address latestDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFromFundMe(latestDeployed);
    }
}

contract WithdrawFromFundMe is Script {
    function withdrawFromFundMe(address _latestDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_latestDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFromFundMe(mostRecentlyDeployed);
    }
}
