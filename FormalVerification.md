# Formal Verification Guide

## 1. Introduction to Formal Verification

### What is Formal Verification?
Formal Verification (FV) uses mathematical modeling and logical analysis to ensure program security and correctness. A key aspect of FV is symbolic execution, which assigns symbolic values to inputs, allowing the exploration of various program paths in a single analysis. 

This technique helps verify if a program can violate certain conditions or reach risky states, using tools like SMT solvers for feasibility assessment. Symbolic execution thus enhances testing, offering a more comprehensive way to establish a program’s safety and correctness.

### Benefits of Formal Verification

In contrast to conventional execution methods, symbolic execution employs symbolic values for inputs, enabling the examination of all possible execution routes in a single analysis. 

This approach aims to generalize testing and is commonly used to verify whether any program execution can breach a particular property. 

Symbolic execution can demonstrate the unreachability of certain states, thereby affirming the safety or correctness of a program in a more comprehensive manner.

**Comprehensive Analysis of State Space:** Formal verification involves computing and analyzing all possible states a contract can be in during its execution. This meticulous examination helps identify potential flaws or vulnerabilities that might not be evident in traditional testing methods.

In summary, formal verification is ideal for ensuring correctness and security at a more conceptual and absolute level, while fuzzing is more suitable for discovering specific errors and testing invariants in smart contracts.

## 2. Formal Verification Tools We Use

### Tools and Technologies

- [**Halmos:**](https://github.com/a16z/halmos/tree/main)
    An open-source tool that allows developers to reuse unit test properties in formal specifications for the verification of Ethereum smart contract bytecode.
- [**Ityfuzz:**](https://github.com/fuzzland/ityfuzz/tree/master)
    ItyFuzz is a hybrid fuzzer for smart contracts that combines symbolic execution and fuzzing to find errors in smart contracts. Technically, it uses formal verification (concolic execution) assisted by fuzzing algorithms guided by data flow patterns and comparisons.
    It can run on top of Echidna and Scribble.
- [**Kontrol:**](https://github.com/runtimeverification/kontrol)
    Provides a formal representation of the EVM and facilitates symbolic execution of smart contract bytecode, combining KEVM and Foundry.
- [**Pyrometer:**](https://github.com/nascentxyz/pyrometer)
    Combines symbolic execution, abstract interpretation, and static analysis, focused on Solidity but with the potential to be language-agnostic.
- [**hevm:**](https://github.com/ethereum/hevm)
    An EVM implementation for symbolic execution, unit testing, and debugging of smart contracts.
- [**Heimdall:**](https://github.com/Jon-Becker/heimdall-rs/tree/main)
    An advanced tool for smart contract bytecode analysis, specializing in disassembly, control flow graph generation, and decompilation.



### Most Utilized Tools

- Halmos
- Ityfuzz
- Ityfuzz in Echidna
- Kontrol
## 3. How These Tools Work

### Halmos

- An example of using this tool is to perform fuzz and invariant tests through symbolic values, allowing deeper analysis during tests. 
- The implementation of invariant tests is similar but distinct; for example, specific functions can be created to perform invariants using symbolic bytecodes.

#### This would be a small example:


```solidity 


    function check_Invariant_Backdoor(bytes4 selector,address other, address caller) public {
        // Execute an arbitrary tx
        vm.assume(other != caller);

        uint256 oldBalanceOther = IERCOLAS(token).balanceOf(other);
        uint256 oldAllowance = IERCOLAS(token).allowance(other, caller);

        vm.prank(caller);
        (bool success,) = address(token).call(gen_calldata(selector));
        vm.assume(success);

        uint256 newBalanceOther = IERCOLAS(token).balanceOf(other);

    
        if (newBalanceOther < oldBalanceOther) {
            assert(oldAllowance >= oldBalanceOther - newBalanceOther);
        }

    }

/////////////////////////////////////////////////////////////////////////

// HANDLER

/////////////////////////////////////////////////////////////////////////
   
    function gen_calldata(bytes4 selector) internal returns (bytes memory) {

        // Create symbolic values to be included in calldata
        address guy = svm.createAddress("guy");
        address src = svm.createAddress("src");
        address dst = svm.createAddress("dst");
        uint256 wad = svm.createUint256("wad");
        uint256 val = svm.createUint256("val");
        uint256 pay = svm.createUint256("pay");

        // Generate calldata based on the function selector
        bytes memory args;
        if (selector == IERCOLAS(token).changeOwner.selector) {
            args = abi.encode(guy);
        } else if (selector == IERCOLAS(token).changeMinter.selector) {
            args = abi.encode(guy);
        } else if (selector == IERCOLAS(token).mint.selector) {
            args = abi.encode(guy, wad);
        } else if (selector == IERCOLAS(token).inflationControl.selector) {
            args = abi.encode(wad);
        } else if (selector == IERCOLAS(token).inflationRemainder.selector) {
            args = abi.encode();
        } else if (selector == IERCOLAS(token).burn.selector) {
            args = abi.encode(val);
        } else if (selector == IERCOLAS(token).decreaseAllowance.selector) {
            args = abi.encode(src, wad);
        } else if (selector == IERCOLAS(token).increaseAllowance.selector) {
            args = abi.encode(src, wad);
        } else {

            args = svm.createBytes(1024, "data"); 
        }
        return abi.encodePacked(selector, args);
    }
```

#### Another example

```solidity 
    function checkNoBackdoor(bytes4 selector, address caller, address other) public virtual {
        // address caller = svm.createAddress("caller");
        // address other = svm.createAddress("other");
        bytes memory args = svm.createBytes(1024, 'data');
        vm.assume(other != caller);

        uint256 oldBalanceOther = (token).balanceOf(other);

        uint256 oldAllowance = (token).allowance(other, caller);

        vm.prank(caller);
        (bool success,) = address(token).call(abi.encodePacked(selector, args));
        vm.assume(success);

        uint256 newBalanceOther = (token).balanceOf(other);

        if (newBalanceOther < oldBalanceOther) {
            assert(oldAllowance >= oldBalanceOther - newBalanceOther);
        }
    }
```

#### Or an example from Bastion

```solidity 
    function check_test_initiatePayment(
        uint256 amount,
        uint256 _validUntil,
        uint256 paymentInterval,
        address FalseToken) public {

        address subscriber = holders[0];

        vm.assume (1 ether <= amount && amount <= 1000 ether);
        vm.assume (1 days <= paymentInterval && paymentInterval <= 365 days);
        vm.assume (1 days <= _validUntil && _validUntil <= 365 days);
        vm.assume (FalseToken != address(token));

        uint256 validUntil = block.timestamp + _validUntil;
        vm.assume(amount > 0 && paymentInterval > 0 && validUntil > block.timestamp);

        vm.prank(subscriber);
        bool hasFailed = false;
        try initiator.registerSubscription(subscriber, amount, validUntil, paymentInterval, FalseToken) {
        } catch {
            hasFailed = true;
        }
        if (hasFailed) {
            fail("La llamada a registerSubscription ha revertido de manera inesperada.");
        }

        ISubExecutor.SubStorage memory sub = initiator.getSubscription(subscriber);
        assertEq(sub.amount, amount);
        assertEq(sub.validUntil, validUntil);
        assertEq(sub.paymentInterval, paymentInterval);
        assertEq(sub.subscriber, subscriber);
        assertEq(sub.initiator, address(initiator));
        assertEq(sub.erc20Token, address(FalseToken));
        assertEq(sub.erc20TokensValid, FalseToken != address(0));

        uint256 warpToTime = block.timestamp + 1 days;
        vm.assume(warpToTime > block.timestamp && warpToTime < validUntil);
        vm.warp(warpToTime);
// vm.warp(svm.createUint(64, "timestamp2"))

        vm.prank(subscriber);
        bool success;
        try initiator.initiatePayment(subscriber) {
            success = true;
        } catch {
            success = false;
        }
        assert(success == true);
    }
````

### Ityfuzz:

- Being a new tool, there is limited documentation available, but it is beginning to demonstrate all its capabilities as it combines formal verification (concolic execution) assisted by fuzzing algorithms guided by data flow patterns and comparisons.
- To use this tool, we need to have [Blazo](https://github.com/fuzzland/blazo) installed.









#### An example of its use can be:

- **In these example contracts:**
    We demonstrate one of the functionalities of ityfuzz, which involves using the **bug()** keyword. This function aims to identify potential invariant violations within the code where it is incorporated.
- **Strategic Placement:**
    In these cases, we have strategically placed it within the contract itself. This eliminates the need to write a separate test and allows us to uncover potential issues.
- [**Multiple Oracles:**](https://github.com/fuzzland/ityfuzz/tree/master/src/evm/oracles)
    Currently, ityfuzz is equipped with various oracles that are trained to detect vulnerabilities within the code.
- **Result Reporting:**
    The result indicates whether ityfuzz has identified any issues and provides the steps it followed to potentially exploit them.

```solidity 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/solidity_utils/lib.sol";

contract Gate {
    bool public locked = true;
    uint256 public timestamp = block.timestamp;
    uint8 private number1 = 10;
    uint16 private number2 = 255;
    bytes32[3] private data;

    constructor(bytes32 _data1, bytes32 _data2, bytes32 _data3) {
        data[0] = _data1;
        data[1] = _data2;
        data[2] = _data3;
    }

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    function resolve(bytes memory _data) public {
        require(msg.sender == tx.origin);
        (bool success, ) = address(this).call(_data);
        require(success, "Call failed");
    }

    function unlock(bytes memory _data) public onlyThis {
        require(bytes16(_data) == bytes16(data[2]));
        // locked = false;
        bug();
    }

    // function isSolved() public view returns (bool) {
    //     return !locked;
    // }
}
````

#### Result:

![ity1](https://hackmd.io/_uploads/Sk2nY889T.png)


#### Or this other case:


```solidity 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "lib/solidity_utils/lib.sol";

contract BytecodeVault {
    // address public owner;

    // constructor() public payable { 
    //     owner = msg.sender;        
    // }       

    modifier onlyBytecode() {
        require(msg.sender != tx.origin, "No high-level contracts allowed!");
        _;
    }

    function withdraw(bytes memory senderCode) external onlyBytecode {
        uint256 sequence = 0xdeadbeef;

        // bytes memory senderCode;
        // address bytecaller = msg.sender;

        // assembly {
        //     let size := extcodesize(bytecaller)
        //     senderCode := mload(0x40)
        //     mstore(0x40, add(senderCode, and(add(size, 0x20), 0x1f), not(0x1f)))
        //     mstore(senderCode, size)
        //     extcodecopy(bytecaller, add(senderCode, 0x20), 0, size)
        // }
                
        require(senderCode.length % 2 == 1, "Bytecode length must be even!");

        for (uint256 i = 0; i < senderCode.length - 3; i++) {
            if (senderCode[i] == bytes1(uint8(sequence >> 24))) {
                if (senderCode[i + 1] == bytes1(uint8((sequence >> 16) & 0xFF))) {
                    if (senderCode[i + 2] == bytes1(uint8((sequence >> 8) & 0xFF))) {
                        if (senderCode[i + 3] == bytes1(uint8(sequence & 0xFF))) {
                            bug();
                        }
                    }
                }
            }
        }
        // revert("Sequence not found!");
    }

    function isSolved() public view returns (bool) {
        return address(this).balance == 0;
    }

}
```

#### Result:

![ity2](https://hackmd.io/_uploads/ryYHqIUca.png)


### Kontrol:

- Kontrol is a powerful tool that works on top of KEVM and has very useful functions for usage, such as:

    - The Kontrol  [KCFG visualizer](https://docs.runtimeverification.com/kontrol/guides/kontrol-example/k-control-flow-graph-kcfg). This tool allows you to analyze the state of the virtual machine at different points (nodes) during the symbolic execution.

![image](https://hackmd.io/_uploads/S1asiUU9a.png)


#### Example of implementation:


```solidity 
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenTest is Test {
    Token token; 

    address Alice;
    address Bob;
    address Eve;

    function setUp() public {
        token = new Token();
        Alice = makeAddr("Alice");
        Bob = makeAddr("Bob");
        Eve = makeAddr("Eve");
        token.mint(Alice, 10 ether);
        token.mint(Bob, 20 ether);
        token.mint(Eve, 30 ether);
    }

    function testTransfer(address from, address to, uint256 amount) public {
        // This proof has a high number of branches when executed with kontrol due to the 
        // fact that both `from` and `to` args could be each of the following addresses 
        // (Alice, Bob, Eve, address(this), address(vm), address(token)).

        // The first four `vm.assume` calls allow the symbolic arguments `from` and `to` to
        // take values that have been initialized in the token storage with a valid balance.

        // This is a toy example to show how branchings and constraints work.

        vm.assume(from == Alice || from == Bob || from == Eve);
        vm.assume(to == Alice || to == Bob || to == Eve);
        vm.assume(from != address(this) && from != address(vm) && from != address(token));
        vm.assume(to != address(this) && to != address(vm) && to != address(token));
        vm.assume(to != from);

        vm.assume(token.balanceOf(from) >= amount);

        uint256 preBalanceFrom = token.balanceOf(from);
        uint256 preBalanceTo = token.balanceOf(to);

        vm.prank(from);
        token.transfer(to, amount);

        if(from == to) {
            assertEq(token.balanceOf(from), preBalanceFrom);
            assertEq(token.balanceOf(to), preBalanceTo);
        } else {
            assertEq(token.balanceOf(from), preBalanceFrom - amount);
            assertEq(token.balanceOf(to), preBalanceTo + amount);
        }
    }
}

```



## 4. Our Approach and Methodology

### Integration with Client Workflow

These are examples of how we have used these tools in other projects, having conducted analysis using Halmos, Foundry, Echidna, Medusa, Ityfuzz..

Here we show in detail what we have done to perform the tests:

- https://github.com/scab24/Autonolas
- https://allthingsfuzzy.substack.com/p/formal-verification-in-practice-halmos
- https://github.com/scab24/Formal_Verification

## 5. Client Prerequisites

### Necessary Information

To conduct an effective verification, we require:
- System documentation and requirement specifications.
- Access to the source code or relevant parts of it.

## 6. Costs and Pricing Models

### Pricing Structure
We offer a flexible pricing structure, varying based on the complexity and size of the project. Costs are estimated based on:
- Code complexity.
- Length and depth of the analysis required.

## 7. Conclusion and Call to Action

### Why Choose Us?


### Contact

To get in touch with us, you can write to us at:
- [Twitter:](https://twitter.com/TheBlockChainer) bloqarl
- [Twitter:](https://twitter.com/Seecoalba) secoalba
- [Telegram]( https://t.me/vendrell46)





