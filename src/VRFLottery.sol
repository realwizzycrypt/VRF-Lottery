// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/// @title VRFLottery
/// @author WizzyCrypt
/// @notice A decentralized lottery contract using Chainlink VRF for random winner selection.
/// @dev This contract allows players to enter a lottery by sending ETH, and an admin selects a winner using Chainlink VRF's random number.
/// @dev The fulfillRandomWords() function visibility was modified from 'internal' to 'public' in this project.
/// @dev To run the project, ensure that the fulfillRandomWords() function visibility is modified...
/// @dev ...from 'internal' to 'public' in the `src/VRFLottery.sol` file and the `@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol` file.

contract VRFLottery is VRFConsumerBaseV2Plus {
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint16 private constant NUMBER_OF_WORDS = 1;

    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256[] public s_randomWords;
    address public s_admin;
    address[] public s_players;
    address public s_recentWinner;

    constructor(address vrfCoordinator, bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit)
        VRFConsumerBaseV2Plus(vrfCoordinator)
    {
        s_admin = msg.sender;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterLottery() public payable {
        require(msg.value > 0.01 ether, "Not enough ETH");
        s_players.push(msg.sender);
    }

    function randomWinnerSelector() public {
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUMBER_OF_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) public override {
        s_randomWords = randomWords;
    }

    function selectWinner() public onlyAdmin {
        require(s_players.length > 4, "Not enough entries");

        randomWinnerSelector();

        require(s_randomWords.length > 0, "Random words not fulfilled yet");

        uint256 index = s_randomWords[0] % s_players.length;
        address winner = s_players[index];
        s_recentWinner = winner;
        payable(s_recentWinner).transfer(address(this).balance);

        delete s_players;
        delete s_randomWords;
    }

    modifier onlyAdmin() {
        require(msg.sender == s_admin, "Only admin can call this function");
        _;
    }

    function getPlayers() public view returns (address[] memory) {
        return s_players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getRandomWords() public view returns (uint256[] memory) {
        return s_randomWords;
    }
}
