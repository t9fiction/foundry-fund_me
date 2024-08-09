// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter{

    // 0x694AA1769357215DE4FAC081bf1f309aDC325306
    function getPrice(AggregatorV3Interface _priceFeed) internal view returns(uint256) {
        ( ,int256 price,,, ) = _priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 _ethAmount, AggregatorV3Interface _priceFeed) internal view returns(uint256) {
        uint256 ethPrice = getPrice(_priceFeed);
        uint256 ethAmountInUSD = (ethPrice * _ethAmount) / 1e18; 
        return ethAmountInUSD;
    }

    function getVersion() internal view returns(uint256) {
        return AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF).version();
    }

}