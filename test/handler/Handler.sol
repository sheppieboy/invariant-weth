// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../src/WETH9.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {LibAddressSet} from "../helpers/AddressSet.sol";
import {AddressSet} from "../helpers/AddressSet.sol";
import {console} from "forge-std/console.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    using LibAddressSet for AddressSet;

    AddressSet internal _actors;

    WETH9 public weth;

    uint256 public constant ETH_SUPPLY = 120_500_000 ether;

    address internal currentActor;

    modifier createActor() {
        currentActor = msg.sender;
        _actors.add(msg.sender);
        _;
    }

    mapping(bytes32 => uint256) public calls;

    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }

    constructor(WETH9 _weth) {
        weth = _weth;
        deal(address(this), ETH_SUPPLY);
    }

    uint256 public ghost_depositSum;
    uint256 public ghost_withdrawSum;

    function deposit(uint256 amount) public createActor countCall("deposit") {
        amount = bound(amount, 0, address(this).balance);
        _pay(currentActor, amount);
        vm.prank(currentActor);
        weth.deposit{value: amount}();
        ghost_depositSum += amount;
    }

    uint256 public ghost_zeroWithdrawals;

    function withdraw(uint256 callerSeed, uint256 amount) public countCall("withdraw") {
        address caller = _actors.rand(callerSeed);
        amount = bound(amount, 0, weth.balanceOf(caller));
        if (amount == 0) ghost_zeroWithdrawals++;

        vm.startPrank(caller);
        weth.withdraw(amount);
        _pay(address(this), amount);
        vm.stopPrank();

        ghost_withdrawSum += amount;
    }

    receive() external payable {}

    function sendFallback(uint256 amount) public createActor countCall("sendFallback") {
        amount = bound(amount, 0, address(this).balance);
        _pay(currentActor, amount);
        vm.prank(currentActor);
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

    function callSummary() external view {
        console.log("Call summary:");
        console.log("------------------");
        console.log("deposit", calls["deposit"]);
        console.log("withdraw", calls["withdraw"]);
        console.log("sendFallback", calls["sendFallback"]);
        console.log("Zero withdrawals:", ghost_zeroWithdrawals);
    }
}
