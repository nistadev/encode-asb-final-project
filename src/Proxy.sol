// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "forge-std/Test.sol";
contract SafeDeployment is Test{
    event ProxyDeployed(address proxy, address admin);

    function deployProxy(address implementation, address adminOwner, bytes memory data) public returns (address, address) {
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            implementation,
            adminOwner,
            data
        );

        // The ProxyAdmin address can be retrieved from the AdminChanged event
        // emitted during the proxy deployment
        address proxyAdmin = address(uint160(uint256(vm.load(address(proxy), bytes32(uint256(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103))))));

        emit ProxyDeployed(address(proxy), proxyAdmin);

        return (address(proxy), proxyAdmin);
    }
}