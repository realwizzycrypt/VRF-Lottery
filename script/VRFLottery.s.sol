// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {VRFLottery} from "../src/VRFLottery.sol";
import {MockVRFCoordinator} from "../test/MockVRFCoordinator.sol";

contract VRFLotteryScript is Script {
    VRFLottery public vrfLottery;

    address public constant vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 public constant gasLane = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint256 public constant subscriptionId = 0;
    uint32 public constant callbackGasLimit = 500000;

    MockVRFCoordinator mockCoordinator = new MockVRFCoordinator();

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vrfLottery = new VRFLottery(address(mockCoordinator), gasLane, subscriptionId, callbackGasLimit);

        vm.stopBroadcast();
    }
}
