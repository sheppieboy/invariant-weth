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

        bytes4[] memory selectors = new bytes4[](6);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.withdraw.selector;
        selectors[2] = Handler.sendFallback.selector;
        selectors[3] = Handler.approve.selector;
        selectors[4] = Handler.transfer.selector;
        selectors[5] = Handler.transferFrom.selector;
        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
        targetContract(address(handler)); //fuzz and test the helper
    }

    function invariant_conservationOfETH() public {
        assertEq(handler.ETH_SUPPLY(), address(handler).balance + weth.totalSupply());
    }

    function invariant_solvencyDeposits() public {
        assertEq(address(weth).balance, handler.ghost_depositSum() - handler.ghost_withdrawSum());
    }

    function invariant_solvencyBalances() public {
        uint256 sumOfBalances;
        address[] memory actors = handler.actors();
        for (uint256 i = 0; i < actors.length; i++) {
            sumOfBalances += weth.balanceOf(actors[i]);
        }
        assertEq(address(weth).balance, sumOfBalances);
    }
    //we'll check that no individual token owner's balance can exceed the weth.totalSupply().
    //An underflow in token transfer logic might be one way to violate this property:

    function invariant_depositorBalancesLessThanTotalSupply() public {
        address[] memory actors = handler.actors();
        for (uint256 i = 0; i < actors.length; i++) {
            this.assertAccountBalanceLessThanTotalSupply(actors[i]);
        }
    }

    function assertAccountBalanceLessThanTotalSupply(address account) external {
        assertLe(weth.balanceOf(account), weth.totalSupply());
    }

    function invariant_callSummary() public view {
        handler.callSummary();
    }
}
