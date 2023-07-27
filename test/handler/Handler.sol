// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../src/WETH9.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    WETH9 public weth;

    uint256 public constant ETH_SUPPLY = 120_500_000 ether;

    constructor(WETH9 _weth) {
        weth = _weth;
        deal(address(this), ETH_SUPPLY);
    }

    uint256 public ghost_depositSum;
    uint256 public ghost_withdrawSum;

    function deposit(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        weth.deposit{value: amount}();
        ghost_depositSum += amount;
    }

    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, weth.balanceOf(address(this)));
        weth.withdraw(amount);
        ghost_withdrawSum += amount;
    }

    receive() external payable {}

    function sendFallBAck(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        (bool success,) = address(weth).call{value: amount}("");
        require(success);
    }
}
