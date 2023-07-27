// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {WETH9} from "../src/WETH9.sol";
import {Handler} from "./handler/Handler.sol";

contract WETH9Invariants is Test {
    WETH9 public weth;
    Handler public handler;

    function setUp() public {
        weth = new WETH9();
        handler = new Handler(weth);

        targetContract(address(handler)); //fuzz and test the helper
    }

    function invariant_conservationOfETH() public {
        assertEq(handler.ETH_SUPPLY(), address(handler).balance + weth.totalSupply());
    }

    function invariant_solvencyDeposits() public {
        assertEq(address(weth).balance, handler.ghost_depositSum() - handler.ghost_withdrawSum());
    }
}
