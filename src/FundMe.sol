// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// library PriceConverter{

//     // 0x694AA1769357215DE4FAC081bf1f309aDC325306 //Sepolia
//     function getPrice() internal view returns(uint256) {
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
//         ( ,int256 price,,, ) = priceFeed.latestRoundData();

//         return uint256(price * 1e10);
//     }

//     function getConversionRate(uint256 _ethAmount) internal view returns(uint256) {
//         uint256 ethPrice = getPrice();
//         uint256 ethAmountInUSD = (ethPrice * _ethAmount) / 1e18;
//         return ethAmountInUSD;
//     }

// }

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256; //Attaching PriceConverter to all uint256
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    address private immutable i_owner;
    address[] private s_funders;
    AggregatorV3Interface private s_priceFeed;
    mapping(address => uint256) private s_addressToAmountFunded;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Send atleast 5$ worth of Ether"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 _fundersLength = s_funders.length;
        for (uint256 i = 0; i < _fundersLength; i++) {
            address s_funder = s_funders[i];
            s_addressToAmountFunded[s_funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Send Failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address s_funder = s_funders[i];
            s_addressToAmountFunded[s_funder] = 0;
        }
        s_funders = new address[](0);
        // Three types of functions to withdraw
        // First -> Using Transfer
        // payable(msg.sender).transfer(address(this).balance);

        // Second -> using send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        // Third -> Using Call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Send Failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner,"Sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        } //Saves gas instead of require
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     ** Getter function for private variables
     */

    function getAddressToAmountFunder(
        address _fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[_fundingAddress];
    }

    function getFunder(uint256 _index) external view returns (address) {
        return s_funders[_index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
