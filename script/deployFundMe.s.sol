// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/fundme.sol";
import {HelperConfig} from "./helperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast(); //beofre start broadcast, not a real tx

        //MOCK
        FundMe _fundMe = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return _fundMe;
    }
}
