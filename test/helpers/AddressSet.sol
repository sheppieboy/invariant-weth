// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

struct AddressSet {
    address[] addrs;
    mapping(address => bool) saved;
}

library LibAddressSet {
    function add(AddressSet storage set, address addr) internal {
        if (set.saved[addr] == false) {
            set.addrs.push(addr);
            set.saved[addr] = true;
        }
    }

    function contains(AddressSet storage set, address addr) internal view returns (bool) {
        return set.saved[addr];
    }

    function count(AddressSet storage set) internal view returns (uint256) {
        return set.addrs.length;
    }

    //forEach will call the given function for every address in our set
    function forEach(AddressSet storage set, function(address) external returns(address[] memory) func) internal {
        for (uint256 i; i < set.addrs.length; i++) {
            func(set.addrs[i]);
        }
    }

    //reduce will call a given function that must return a uint256 and add its result to an accumulator
    function reduce(AddressSet storage set, uint256 acc, function(uint256, address) external returns(uint256) func)
        internal
        returns (uint256)
    {
        for (uint256 i; i < set.addrs.length; i++) {
            acc = func(acc, set.addrs[i]);
        }
        return acc;
    }
}
