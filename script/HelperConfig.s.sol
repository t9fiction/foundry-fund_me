// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../src/test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // This contract provides configuration for different chains.

    // Type creation
    struct NetworkConfig {
        address ethusdt; //ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            ethusdt: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            ethusdt: 0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46
        });
        return mainnetConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.ethusdt != address(0)){
            return activeNetworkConfig;
        }
        // Deploy the MOCK since there r no contracts on Anvil
        // Grab the mock addresses
        vm.startBroadcast();
        MockV3Aggregator mockPriceEthUsdt = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            ethusdt: address(mockPriceEthUsdt)
        });

        return anvilConfig;
    }
}
