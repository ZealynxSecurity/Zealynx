## Foundry Challenge #1:
### Impersonate a Billionaire in a Smart Contract Test

Imagine you're testing a smart contract that grants special permissions only to billionaire addresses. You need to verify that your contract behaves correctly when interacting with such high-profile Ethereum accounts. But how do you simulate transactions from a billionaire without actually needing billions in Ether?

**Your mission:** 
Figure out how to impersonate a billionaire Ethereum address in your smart contract test without owning the actual funds.

**Hint:**
Foundry has a "cheat code" that lets you pretend to be any Ethereum address during your tests. This tool is crucial for testing permissions and access controls effectively.

### Can you guess which Foundry cheat code allows you to do this, and how would you use it in your test script?

:arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down:

###  Solution to the Challenge: Impersonate a Billionaire in a Smart Contract Test

To impersonate a billionaire or any other Ethereum address in your smart contract tests using Foundry, you can use the vm.prank cheat code. This cheat code allows you to make a call as if it were coming from another address, without actually needing control over that address. Here's how you would apply it in a test script for a contract that checks if an address is a billionaire.

**Example Contract:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract BillionaireClub {
    mapping(address => bool) public billionaires;

    function addBillionaire(address _member) external {
        require(isBillionaire(_member), "Not a billionaire");
        billionaires[_member] = true;
    }

    function isBillionaire(address _member) public pure returns (bool) {
        // Simplified check for demonstration purposes
        return _member == address(1); // Let's say address(1) is a known billionaire
    }
}

contract BillionaireClubTest is Test {
    BillionaireClub public club;

    function setUp() public {
        club = new BillionaireClub();
    }

    function testImpersonateBillionaire() public {
        address billionaire = address(1); // Known billionaire address
        vm.prank(billionaire);
        club.addBillionaire(billionaire);

        assertTrue(club.billionaires(billionaire));
    }
}
```

### Explanation:

- Contract Setup: The BillionaireClub contract has a function addBillionaire that requires the caller to be a billionaire, as verified by the isBillionaire function. For demonstration, isBillionaire just checks if the address is address(1), which we pretend is a billionaire.
  
- Test Contract: In the BillionaireClubTest contract, the setUp function initializes a new instance of BillionaireClub.
  
- Test Function (testImpersonateBillionaire): This function uses vm.prank to simulate a transaction from address(1), which is allowed to add itself as a billionaire. The test checks if the billionaire status is correctly updated in the contract.