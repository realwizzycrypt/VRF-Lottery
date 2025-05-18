// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {VRFLottery} from "../src/VRFLottery.sol";
import {MockVRFCoordinator} from "./MockVRFCoordinator.sol";

contract VRFLotteryTest is Test {
    VRFLottery public vrfLottery;

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address user5 = makeAddr("user5");

    address public constant vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 public constant gasLane = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint256 public constant subscriptionId = 0;
    uint32 public constant callbackGasLimit = 500000;

    function setUp() public {
        MockVRFCoordinator mockCoordinator = new MockVRFCoordinator();
        vrfLottery = new VRFLottery(address(mockCoordinator), gasLane, subscriptionId, callbackGasLimit);

        // Set the VRFLottery as the consumer in MockVRFCoordinator
        mockCoordinator.setConsumer(address(vrfLottery));

        vm.deal(user1, 3 ether);
        vm.deal(user2, 3 ether);
        vm.deal(user3, 3 ether);
        vm.deal(user4, 3 ether);
        vm.deal(user5, 3 ether);
    }

    function test_can_enter_lottery() public {
        vm.prank(user1);
        vrfLottery.enterLottery{value: 0.02 ether}();
        address[] memory players = vrfLottery.getPlayers();
        assertEq(players[0], user1);
    }

    function test_randomWinnerSelector() public {
        vm.prank(user1);
        vrfLottery.enterLottery{value: 0.02 ether}();

        vm.prank(user2);
        vrfLottery.enterLottery{value: 0.02 ether}();

        vm.prank(address(this));
        vrfLottery.randomWinnerSelector();

        uint256[] memory randomWords = vrfLottery.getRandomWords();
        assertEq(randomWords.length, 1);
        assertEq(randomWords[0], 7);
    }

    function test_selectWinner() public {
        vm.prank(user1);
        vrfLottery.enterLottery{value: 3 ether}();

        vm.prank(user2);
        vrfLottery.enterLottery{value: 3 ether}();

        vm.prank(user3);
        vrfLottery.enterLottery{value: 3 ether}();

        vm.prank(user4);
        vrfLottery.enterLottery{value: 3 ether}();

        vm.prank(user5);
        vrfLottery.enterLottery{value: 3 ether}();

        vm.prank(address(this));
        vrfLottery.randomWinnerSelector();
        vrfLottery.selectWinner();

        assertEq(vrfLottery.s_recentWinner().balance, 15 ether);
        assertEq(address(vrfLottery).balance, 0);
    }
}
