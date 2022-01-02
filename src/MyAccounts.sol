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
