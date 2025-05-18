// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFLottery} from "../src/VRFLottery.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract MockVRFCoordinator {
    VRFLottery public vrfConsumer;

    constructor() {
        // We do not set the vrfConsumer in the constructor; we set it later in setConsumer();
    }

    function setConsumer(address _consumer) external {
        vrfConsumer = VRFLottery(_consumer);
    }

    function requestRandomWords(VRFV2PlusClient.RandomWordsRequest calldata /* req */ ) external returns (uint256) {
        // Simulate Chainlink VRF callback
        uint256[] memory words = new uint256[](1); // Initialize array with length 1
        /// @dev Setting this to 7 will make user3 the winner (out of 5 entrants).
        /// @dev Set to your preferred number to test different winners.
        words[0] = 7; // Set the mock random number.
        vrfConsumer.fulfillRandomWords(0, words);
        return 0;
    }
}
