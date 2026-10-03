// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IAdapter { function swap() external payable; }

/// Local native-asset router. Chain-scoped request IDs are NOT a bridge protocol.
contract Router {
    address public immutable owner;
    mapping(address => bool) public allowed;
    mapping(bytes32 => bool) public used;
    bool private locked;
    error Unauthorized(); error InvalidRoute(); error Reentrant(); error Slippage(); error PaymentFailed();
    event Routed(bytes32 indexed request, address indexed recipient, uint256 input, uint256 output);
    constructor() { owner = msg.sender; }
    receive() external payable {}
    function setAdapter(address adapter, bool enabled) external {
        if (msg.sender != owner) revert Unauthorized();
        if (adapter.code.length == 0) revert InvalidRoute();
        allowed[adapter] = enabled;
    }
    function requestId(address caller, bytes32 nonce) public view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, address(this), caller, nonce));
    }
    function route(address adapter, address payable recipient, bytes32 nonce, uint256 minOut, uint256 deadline) external payable returns (uint256 out) {
        if (locked) revert Reentrant();
        bytes32 id = requestId(msg.sender, nonce);
        if (!allowed[adapter] || recipient == address(0) || recipient == address(this) || msg.value == 0 || minOut == 0 || deadline < block.timestamp || used[id]) revert InvalidRoute();
        locked = true; used[id] = true;
        uint256 baseline = address(this).balance - msg.value;
        IAdapter(adapter).swap{value: msg.value}();
        out = address(this).balance - baseline;
        if (out < minOut) revert Slippage();
        (bool ok,) = recipient.call{value: out}("");
        if (!ok) revert PaymentFailed();
        locked = false;
        emit Routed(id, recipient, msg.value, out);
    }
}
