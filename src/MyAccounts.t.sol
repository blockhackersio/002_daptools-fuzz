// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "./MyAccounts.sol";

contract TestUser {
    MyAccounts a;

    constructor(MyAccounts _a) {
        a = _a;
    }

    function deposit() public payable {
        a.deposit{value: msg.value}();
    }

    function withdraw(uint256 _amount) public {
        a.withdraw(_amount);
    }

    function balance() public view returns (uint256) {
        return a.balance();
    }

    receive() external payable {}
}

contract MyAccountsTest is DSTest {
    MyAccounts accounts;
    TestUser user1;
    TestUser user2;

    function setUp() public {
        accounts = new MyAccounts();
        user1 = new TestUser(accounts);
        user2 = new TestUser(accounts);
    }

    modifier notZero(uint256 _amt) {
        if (_amt == 0) return;
        _;
    }
    modifier lessThan1000eth(uint256 _amt) {
        if (_amt > 1000 ether) return;
        _;
    }

    modifier transferEthTo(TestUser _user, uint256 _amt) {
        payable(address(_user)).transfer(_amt);
        _;
    }

    function test_setup() public transferEthTo(user1, 1 ether) {
        assertEq(address(user1).balance, 1 ether);
    }

    function test_balance() public transferEthTo(user1, 1 ether) {
        user1.deposit{value: 1 ether}();
        assertEq(user1.balance(), 1 ether);
    }

    function test_balanceFuzz(uint256 _amt)
        public
        notZero(_amt)
        lessThan1000eth(_amt)
        transferEthTo(user1, _amt)
    {
        user1.deposit{value: _amt}();
        assertEq(user1.balance(), _amt);
    }

    receive() external payable {}
}
