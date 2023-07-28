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

    function rand(AddressSet storage set, uint256 seed) internal view returns (address) {
        if (set.addrs.length > 0) {
            return set.addrs[seed % set.addrs.length];
        } else {
            return address(0xc0ffee);
        }
    }
}
