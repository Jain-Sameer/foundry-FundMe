// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fundme.sol";
import {DeployFundMe} from "../../script/deployFundMe.s.sol";

contract FundMeTest is Test, DeployFundMe {
    uint256 number = 1;
    FundMe fundMe;
    address USER = makeAddr("TEST");
    uint256 constant sendValue = 0.1 ether;
    uint256 constant GASPRICE = 1;

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
        console.log("Owner: ", fundMe.getOwner());
        assertEq(fundMe.getOwner(), msg.sender);
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

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: sendValue}();

        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: sendValue}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Asser
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank();
            // vm.deal();
            // hoax() does prank and deal does both
            hoax((address(i)), sendValue);
            fundMe.fund{value: sendValue}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GASPRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasEnd();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.GASPRICE();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);

        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFunders_Cheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank();
            // vm.deal();
            // hoax() does prank and deal does both
            hoax((address(i)), sendValue);
            fundMe.fund{value: sendValue}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GASPRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        // uint256 gasEnd = gasEnd();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.GASPRICE();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);

        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
