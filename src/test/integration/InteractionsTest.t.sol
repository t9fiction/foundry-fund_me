// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../FundMe.sol";
import {DeployFundMe} from "../../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../../script/Interactions.s.sol";

contract IntegractionsTest is Test{
    
    FundMe fundMe;

    uint256 constant GAS_PRICE = 1;

    address USER = makeAddr("user"); //Function to create an address for testing
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE); //This will give fake balance to the USER for testing
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        // vm.deal(USER, 1e18);
        // vm.deal(address(this), 1 ether);
        fundFundMe.fundFundMe(address(fundMe));

        // address funder = fundMe.getFunder(0);
        // assertEq(funder, USER);
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}