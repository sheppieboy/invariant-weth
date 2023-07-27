// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../src/WETH9.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {LibAddressSet} from "../helpers/AddressSet.sol";
import {AddressSet} from "../helpers/AddressSet.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    using LibAddressSet for AddressSet;

    AddressSet internal _actors;

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
        _pay(msg.sender, amount);
        vm.prank(msg.sender);
        weth.deposit{value: amount}();
        ghost_depositSum += amount;
    }

    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, weth.balanceOf(msg.sender));
        vm.startPrank(msg.sender);
        weth.withdraw(amount);
        _pay(address(this), amount);
        vm.stopPrank();
        ghost_withdrawSum += amount;
    }

    receive() external payable {}

    function sendFallBack(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        _pay(msg.sender, amount);
        vm.prank(msg.sender);
        (bool success,) = address(weth).call{value: amount}("");
        require(success, "sendFallback failed");
        ghost_depositSum += amount;
    }

    function _pay(address to, uint256 amount) private {
        (bool success,) = to.call{value: amount}("");
        require(success, "private pay() failed");
    }

    function actors() external view returns (address[] memory) {
        return _actors.addrs;
    }
}
