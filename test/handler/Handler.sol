// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../src/WETH9.sol";

contract Handler {
    WETH9 public weth;

    constructor(WETH9 _weth) {
        weth = _weth;
    }
}
