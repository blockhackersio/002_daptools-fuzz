// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

contract App {
    string greeting;

    constructor(string memory _greeting) {
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }
}
