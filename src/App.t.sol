// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./App.sol";

contract AppTest is DSTest {
    App app;

    function setUp() public {
        app = new App("Hello World");
    }

    function test_basic_sanity() public {
        assertEq(app.greet(), "Hello World");
    }
}
