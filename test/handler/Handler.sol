// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../src/WETH9.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    WETH9 public weth;

    constructor(WETH9 _weth) {
        weth = _weth;
        deal(address(weth), 10 ether);
    }

    function deposit(uint256 amount) public {
        weth.deposit{value: amount}();
    }
}
