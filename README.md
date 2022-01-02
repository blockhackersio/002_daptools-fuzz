# Dapp tools tips and tricks

There are some really useful techniques for using dapp tools effectively.

1. Contracts become your users
1. Modifiers are setup macros
1. Fuzz testing
1. Symbolic execution

## Contracts become your users.

Using contracts as users can be weird at first but after a while it becomes pretty easy.

Let's say you have a contract that maintains eth accounts.

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

contract MyAccounts {
    // required to
    receive() external payable {}

    mapping(address => uint256) accounts;

    function deposit() external payable {
        accounts[msg.sender] += msg.value;
    }

    function balance() external view returns (uint256) {
        return accounts[msg.sender];
    }

    function withdraw(uint256 _amount) external {
        require(accounts[msg.sender] > _amount);
        accounts[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}

```

In order to test this we need users with addresses. How do you test each individual account within the context of solidity?

Answer: You use a contract to act as `msg.sender`

This involves a few pieces. Here is how we can do this.

First we create a TestUser contract and pass through the contract under test we want to wrap in the constructor.

```solidity
contract TestUser {
    MyAccounts a;

    constructor(MyAccounts _a) {
        a = _a;
    }
}
```

Next we can call any method on the passed through contract by forwarding the relevant call to the underlying contract.

```solidity
contract TestUser {
    MyAccounts a;

    constructor(MyAccounts _a) {
        a = _a;
    }

    function balance() public view returns (uint256) {
        return a.balance();
    }

    receive() external payable {}
}
```

We can use the setup function of the testing contract to wire up our users.

```solidity

contract MyAccountsTest is DSTest {
    MyAccounts accounts;
    TestUser user1;

    function setUp() public {
        accounts = new MyAccounts();
        user1 = new TestUser(accounts);
    }

    // ...
}
```

Now we can call the balance function as our user.

```solidity
function test_balance() public {
    // deposit 1 ether with msg.sender set to be our user.
    user1.deposit{value: 1 ether}();

    // call balance as user
    assertEq(user1.balance(), 1 ether);
}
```

## Modifiers become setup macros

In contracts solidity modifiers should only really be used for view functionality to check invariants as otherwise they lead to unnecessary complexity but in testing we can use them however we want. In testing we need to create modular setup instructions for each test. This helps setup account balances or recombine steps for a test.

For example we can use a modifier to ensure that a user has enough ether to carry out a test:

```solidity

modifier ensureEther(TestUser _user, uint256 _amt){
    if(address(_user).balance < _amt){
        payable(address(_user)).transfer(_amt);
    }
    _;
}

function test_balance() public ensureEther(user1, 1 ether) {
    user1.deposit{value: 1 ether}();
    assertEq(user1.balance(), 1 ether);
}
```
