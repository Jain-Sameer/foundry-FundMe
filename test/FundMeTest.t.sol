// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/fundme.sol";
import {DeployFundMe} from "../script/deployFundMe.s.sol";

contract FundMeTest is Test, DeployFundMe {
    uint256 number = 1;
    FundMe fundMe;
    address USER = makeAddr("TEST");
    uint256 constant sendValue = 0.1 ether;

    function setUp() external {
        DeployFundMe new_fundMe = new DeployFundMe();
        fundMe = new_fundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testMINDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsSender() public view {
        console.log("sender: ", msg.sender);
        console.log("Owner: ", fundMe.i_owner());
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionisAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesWithEnoughETH() public {
        vm.prank(USER);
        fundMe.fund{value: sendValue}();
        uint amountFunded = fundMe.getAddressToAmountFunded(USER);
        console.log(USER.balance);
        assertEq(amountFunded, sendValue);
    }
}
