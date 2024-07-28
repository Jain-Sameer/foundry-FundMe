// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fundme.sol";
import {DeployFundMe} from "../../script/deployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    address USER = makeAddr("TEST");
    FundMe public fundMe;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, 10 ether);
    }

    function testuserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        vm.prank(USER);
        fundMe.fund{value: 1e18}();

        WithdrawFundMe _withdrawFundMe = new WithdrawFundMe();
        _withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
