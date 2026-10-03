// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "../src/Router.sol";

interface Vm {
    function deal(address,uint256) external;
    function prank(address) external;
    function expectRevert(bytes4) external;
    function warp(uint256) external;
    function chainId(uint256) external;
    function startBroadcast() external;
    function stopBroadcast() external;
}
contract MockAdapter is IAdapter {
    uint256 public rate = 10000;
    receive() external payable {}
    function setRate(uint256 r) external { rate = r; }
    function swap() external payable { (bool ok,) = msg.sender.call{value:msg.value * rate / 10000}(""); require(ok); }
}
contract ReenterAdapter is IAdapter {
    Router public router; bool public rejected;
    constructor(Router r) { router = r; }
    function swap() external payable {
        try router.route{value:1}(address(this),payable(address(0x123)),bytes32(uint256(99)),1,block.timestamp) { revert("reentry accepted"); } catch (bytes memory reason) { require(bytes4(reason)==Router.Reentrant.selector,"wrong failure"); rejected = true; }
        (bool ok,) = msg.sender.call{value:msg.value}(""); require(ok);
    }
    receive() external payable {}
}
contract RejectRecipient { receive() external payable { revert("no"); } }
contract RouterTest {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    Router router; MockAdapter adapter; address payable recipient = payable(address(0xBEEF));
    receive() external payable {}
    function setUp() public { router = new Router(); adapter = new MockAdapter(); router.setAdapter(address(adapter),true); vm.deal(address(this),100 ether); vm.deal(address(adapter),100 ether); }
    function send(uint256 amount,bytes32 nonce,uint256 minOut) internal returns(uint256) { return router.route{value:amount}(address(adapter),recipient,nonce,minOut,block.timestamp); }
    function testRouteMeasuresOutput() public { uint256 b=recipient.balance;require(send(1 ether,0,1 ether)==1 ether);require(recipient.balance-b==1 ether);require(address(router).balance==0); }
    function testAccessControl() public { vm.prank(address(0xCAFE));vm.expectRevert(Router.Unauthorized.selector);router.setAdapter(address(adapter),false); }
    function testReplayRejected() public { send(1 ether,0,1);vm.expectRevert(Router.InvalidRoute.selector);send(1 ether,0,1); }
    function testSlippageRollsBackNonceAndBalances() public { uint256 beforeBalance=address(this).balance;adapter.setRate(9000);vm.expectRevert(Router.Slippage.selector);send(1 ether,0,1 ether);require(!router.used(router.requestId(address(this),0)));require(address(this).balance==beforeBalance);adapter.setRate(10000);send(1 ether,0,1 ether); }
    function testExpiredRoute() public { vm.warp(10);vm.expectRevert(Router.InvalidRoute.selector);router.route{value:1}(address(adapter),recipient,0,1,9); }
    function testUnapprovedAdapter() public { router.setAdapter(address(adapter),false);vm.expectRevert(Router.InvalidRoute.selector);send(1 ether,0,1); }
    function testZeroRecipient() public { vm.expectRevert(Router.InvalidRoute.selector);router.route{value:1}(address(adapter),payable(address(0)),0,1,block.timestamp); }
    function testZeroMinimum() public { vm.expectRevert(Router.InvalidRoute.selector);send(1,0,0); }
    function testReentrancyRejected() public { ReenterAdapter evil=new ReenterAdapter(router);router.setAdapter(address(evil),true);router.route{value:1 ether}(address(evil),recipient,0,1,block.timestamp);require(evil.rejected());require(address(router).balance==0); }
    function testRejectingRecipientRollsBack() public { RejectRecipient rejector=new RejectRecipient();vm.expectRevert(Router.PaymentFailed.selector);router.route{value:1}(address(adapter),payable(address(rejector)),0,1,block.timestamp);require(!router.used(router.requestId(address(this),0))); }
    function testChainDomainSeparation() public { bytes32 a=router.requestId(address(this),0);vm.chainId(42161);bytes32 b=router.requestId(address(this),0);require(a!=b);vm.chainId(10);require(b!=router.requestId(address(this),0)); }
    function testCallerDomainSeparation() public { require(router.requestId(address(this),0)!=router.requestId(address(0xCAFE),0)); }
    function testDonationNotCountedAsOutput() public { vm.deal(address(router),10 ether);adapter.setRate(5000);vm.expectRevert(Router.Slippage.selector);send(1 ether,0,1 ether);require(address(router).balance==10 ether); }
    function testFuzz_OutputAndConservation(uint96 raw,uint16 rate) public { uint256 amount=uint256(raw)%1 ether+10000;uint256 r=uint256(rate)%10001+5000;adapter.setRate(r);uint256 expected=amount*r/10000;uint256 b=recipient.balance;require(send(amount,bytes32(uint256(raw)),expected)==expected);require(recipient.balance-b==expected);require(address(router).balance==0); }
    function testFuzz_SlippageAlwaysReverts(uint96 raw) public { uint256 amount=uint256(raw)%1 ether+2;adapter.setRate(5000);vm.expectRevert(Router.Slippage.selector);send(amount,bytes32(uint256(raw)),amount);require(!router.used(router.requestId(address(this),bytes32(uint256(raw))))); }
}
contract Handler {
    Router public router;MockAdapter public adapter;uint256 public counter;uint256 public totalInput;uint256 public totalOutput;
    constructor(Router r,MockAdapter a) { router=r;adapter=a; }
    receive() external payable {}
    function swap(uint96 raw) public { uint256 amount=uint256(raw)%0.001 ether+1; if(address(this).balance<amount)return;counter++;totalInput+=amount;totalOutput+=router.route{value:amount}(address(adapter),payable(address(this)),bytes32(counter),amount,block.timestamp); }
}
contract RouterInvariantTest {
    Vm constant vm=Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    Router router;Handler handler;address[] targets;
    function setUp() public { router=new Router();MockAdapter a=new MockAdapter();router.setAdapter(address(a),true);handler=new Handler(router,a);vm.deal(address(handler),1 ether);targets.push(address(handler)); }
    function targetContracts() public view returns(address[] memory){return targets;}
    function invariant_NoRouterResidue() public view { require(address(router).balance==0); }
    function invariant_Conservation() public view { require(handler.totalInput()==handler.totalOutput());require(address(handler).balance==1 ether); }
}
