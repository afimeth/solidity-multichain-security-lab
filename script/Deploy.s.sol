// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "../src/Router.sol";
interface BroadcastVm { function startBroadcast() external; function stopBroadcast() external; }
contract Deploy {
    BroadcastVm constant vm=BroadcastVm(address(uint160(uint256(keccak256("hevm cheat code")))));
    function run() external returns(Router router) {
        require(block.chainid==31337,"local Anvil only");
        vm.startBroadcast();router=new Router();vm.stopBroadcast();
    }
}
