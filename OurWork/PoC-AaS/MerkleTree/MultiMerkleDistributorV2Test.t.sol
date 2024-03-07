//SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/MultiMerkleDistributorV2.sol";
import "../src/MockCreator.sol";
import "../src/MockERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Merkle} from "./murky/Merkle.sol";


contract MultiMerkleDistributorV2Test is Test {

    MultiMerkleDistributorV2 distributor;
    MockCreator lootCreator;
    MockERC20 token;
    IERC20 CRV;
    IERC20 DAI;

    address admin;
    address mockQuestBoard;
    address[] users;

    address constant TOKEN1_ADDRESS = 0xD533a949740bb3306d119CC777fa900bA034cd52; // CRV
    address constant TOKEN2_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI

    address constant BIG_HOLDER1 = 0xF977814e90dA44bFA03b6295A0616a897441aceC; // CRV holder
    address constant BIG_HOLDER2 = 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8; // DAI holder

    uint256 private constant WEEK = 604800;
    address public immutable userA = makeAddr("userA");
    address public immutable userB = makeAddr("userB");
    bytes32[] public userA_PROOF_2;
    bytes32[] public userB_PROOF_2;



    function setUp() public {
        token = new MockERC20("Test Token", "TT");
        admin = address(this);
        mockQuestBoard = address(1);

        distributor = new MultiMerkleDistributorV2(mockQuestBoard);
        token.mint(address(distributor), 600 ether);

        lootCreator = new MockCreator(admin);

        CRV = IERC20(TOKEN1_ADDRESS);
        DAI = IERC20(TOKEN2_ADDRESS);

        users.push(address(2));
        users.push(address(3));
        users.push(address(4));
        users.push(address(5));
    }


function test_reClaimIssue() public {

    uint256 claimableAmount = 500 ether;
    uint256 questID = 1;
    uint256 period = (block.timestamp / WEEK) * WEEK + WEEK;
    uint256 index = 0; 

    uint256 claimableAmount2 = 100 ether;
    uint256 questID2 = 2;
    uint256 period2 = (block.timestamp / WEEK) * WEEK + WEEK;
    uint256 index2 = 1;

    Merkle m = new Merkle();
    bytes32[] memory leafNodes = new bytes32[](2);
    leafNodes[0] = keccak256(abi.encodePacked(questID,period, index, userA, claimableAmount));
    leafNodes[1] = keccak256(abi.encodePacked(questID2,period2,index2, userB, claimableAmount2));

    bytes32 root = m .getRoot(leafNodes);
    userA_PROOF_2 = m.getProof(leafNodes, 0);
    userB_PROOF_2 = m.getProof(leafNodes, 1);

    assertTrue(m.verifyProof(root, userA_PROOF_2, leafNodes[0]));
    assertTrue(m.verifyProof(root, userB_PROOF_2, leafNodes[1]));

    vm.prank(mockQuestBoard);
    distributor.addQuest(questID, address(token)); 

    vm.prank(mockQuestBoard);
    distributor.addQuestPeriod(questID, period, claimableAmount);

    vm.prank(mockQuestBoard);
    distributor.updateQuestPeriod(questID, period, claimableAmount, root);

    vm.prank(userB);
    distributor.claim(questID, period, index, userA, 500 ether, userA_PROOF_2); 

    vm.prank(userA);
    vm.expectRevert("AlreadyClaimed");
    distributor.claim(questID, period, index, userA, 500 ether, userA_PROOF_2); 
}


}