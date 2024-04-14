# Security system starts with the testing: how to properly battle test your smart contracts

_Bloqarl_  
Published in _Rektoff_  
**16 min read**  
_Dec 5, 2023_

## Welcome to our deep dive into the world of battle-testing Solidity Smart Contracts!
As the backbone of decentralized applications (dApps) and DeFi protocols, ensuring the security and efficiency of these contracts is non-negotiable. Whether you’re a developer, auditor, or just blockchain-curious, this guide will take you through the many ways you have available to test smart contracts.

### Article Agenda
Here is an overview of the topics we are going to cover in this article. The goal is to introduce you to multiple security testing methodologies and tools to create an understanding of how systematic should be approach to security. That’s where Rektoff comes in.

1. **Security is complicated. Security is expensive. Security is time-consuming. Why should I spend time testing if I can ship fast and break things?**
2. **Testing Techniques and Tools:**

   - **Unit Testing** — Foundry
   - **Static Analysis** — Slither, MythX, Solhint
   - **Fuzz Testing** — Foundry
   - **Invariant Testing** — Echidna
   - **Formal Verification** — Certora Prover
   - **Symbolic Execution** — Manticore
   - **Mutation Testing** — Gambit

3. **Final thoughts**

   Security is complicated. Security is expensive. Security is time-consuming. Why should I spend time testing if I can ship faster and break things? This is a potential reason for many projects to deploy smart contracts without proper testing and even without security reviews.

#### Let’s see why you should be avoiding that:

- **Cost of Security Breaches:** In the Web3 space, smart contract bugs can have catastrophic consequences, including significant financial losses and loss of user trust. Systematic security testing might seem expensive and time-consuming upfront, but it is far more cost-effective compared to the potential losses from a security breach or 10% payouts to the whitehats when your protocol is on mainnet.
- **Time Efficiency:** The “move fast and break things” can be risky in a critical DeFi environment where assets are at stake. Systematic security measures might slow down the initial development process, but they save time in the long run by preventing costly and time-consuming fixes after deployment.
- **Evolving Threat Landscape:** The blockchain ecosystem is highly dynamic, with new attack vectors emerging weekly. A deep research and systematic approach to security ensures that your application is prepared for current and future threats, adapting as the landscape evolves.

## Testing Techniques and Tools
The number of options and tools available to test your smart contracts today is quite broad. We don’t want you to get overwhelmed here but rather bring you enough awareness and understanding on how to implement each of them and the importance of a multi-layer systematic testing approach.

### Unit Testing with Foundry
Unit testing with Foundry is all about making sure each individual function in your contract is rock-solid, reducing risks and boosting confidence before your code goes live.

Foundry is built on Forge, a testing framework that’s part of the Foundry suite. Forge lets us write and run these unit tests for our smart contract functions.

The tests are written in Solidity, so that you no longer have to switch languages, like with other existing frameworks, and Foundry is compatible with the EVM, meaning it can accurately mimic how your contract will behave on the Ethereum network.

#### Let’s show a straightforward example so that you can visualize how unit tests look with Foundry:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleCounter {
    uint public counter;
    uint public constant MAX_LIMIT = 10;

    function increment() public {
        require(counter < MAX_LIMIT, "Counter has reached its maximum limit");
        counter += 1;
    }

    function getCounter() public view returns (uint) {
        return counter;
    }
}
```

In this contract, increment increases the counter by 1, and getCounter returns the current value.

This is how the test file written in solidity would look like with two test scenarios:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import "../src/SimpleCounter.sol";

contract SimpleCounterTest is Test {
    SimpleCounter counter;

    function setUp() public {
        counter = new SimpleCounter();
    }

    function testIncrement() public {
        uint beforeIncrement = counter.getCounter();
        counter.increment();
        uint afterIncrement = counter.getCounter();
        assertEq(afterIncrement, beforeIncrement + 1, "Counter should increment by 1");
    }

    function testFailIncrementBeyondMaxLimit() public {
        // Increment counter to its maximum limit
        for(uint i = 0; i < SimpleCounter.MAX_LIMIT; i++) {
            counter.increment();
        }
        // This next increment should fail
        counter.increment();
    }
}
```

That’s right, in Foundry, depending on how the test function name starts—`test` or `testFail`—it defines the test expectations.

### Static Analysis
Static analysis tools examine your code line by line, identifying bugs, vulnerabilities, and bad practices before you even run the code.

What’s great about these tools is that they can be integrated into your CI/CD pipeline, making the analysis an automated part of your development process. So, no need to worry about executing it manually every time.

The feedback from static analysis tools can be educational for developers, highlighting potential areas of improvement and aiding in learning better coding practices.

Also, by using them, you might be able to quickly detect some common vulnerabilities like for instance reentrancy attacks and overflow/underflow issues.

We want to introduce you to the three most popular static analysis tools:

1. **Slither**  
   Developed by Trail of Bits, Slither is a Solidity static analysis framework known for its precision and extensive detection capabilities. It identifies vulnerabilities, code optimization opportunities, and can even provide insights into contract architecture. Slither’s user-friendly nature and detailed output make it a favorite among developers for quick and insightful analysis.

2. **MythX**  
   MythX is a powerful security analysis API for Ethereum smart contracts. It’s known for its comprehensive range of vulnerability detections. It integrates with popular development tools and IDEs, and uses a combination of static and dynamic analysis, including symbolic execution and input fuzzing (we will speak about what are those in a moment). MythX offers thorough security insights, making it suitable for both quick checks and in-depth vulnerability hunts.

3. **Solhint**  
   Solhint is an open-source project focused on linting Solidity code, which helps in enforcing coding style and discovering syntax issues. It provides both security-focused rules and coding style guidelines to improve the overall quality of the code. Solhint allows developers to configure rules to fit their specific project needs, making it adaptable and flexible.

### Fuzz Testing
Fuzzing is a software testing technique where you input a bunch of random, unexpected, or invalid data into a program (in our case, a smart contract) to see how it behaves.

Unlike traditional testing, where you check for specific outcomes, fuzzing helps uncover issues you might not even have thought of. It’s particularly good at finding edge cases—those rare scenarios that might slip through more structured tests.

Fuzzing can be automated, allowing you to run thousands of test cases without manual intervention. And we want to talk to you about the most popular way of automating fuzz tests, with Foundry.

#### Foundry
Foundry’s fuzzing capability automatically generates random inputs for your smart contract functions.

How does it generate those random inputs? We will show you in a moment with an example, but the idea is simple, you need to pass one or more parameters on the test function and the input will be randomly provided by the fuzzer.

Let’s enhance our earlier SimpleCounter contract to make it more interesting for fuzz testing.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleCounter {
    uint public counter;
    uint public constant MAX_LIMIT = 10;

    function increment(uint value) public {
        if (counter + value > MAX_LIMIT) {
            counter = 0; // Reset to 0 if max limit exceeded
        } else {
            counter += value;
        }
    }

    function getCounter() public view returns (uint) {
        return counter;
    }
}
```

Now we want to create two fuzz tests for this contract:

```solidity
function testValidIncrement(uint value) public {
    uint cappedValue = value % (MAX_LIMIT + 1);
    uint expectedValue = cappedValue <= MAX_LIMIT - counter ? counter + cappedValue : 0;

    counter.increment(cappedValue);
    assertEq(counter.getCounter(), expectedValue, "Counter value should be correctly incremented or reset");
}
```

The test ensures that the increment value, when added to the current counter, does not exceed MAX_LIMIT. If it does, the counter should reset to 0, and the test verifies this behaviour.

And the next one:

```solidity
function testCounterReset(uint value) public {
    uint exceedingValue = MAX_LIMIT + value + 1; // Ensure the value exceeds the max limit

    counter.increment(exceedingValue);
    assertEq(counter.getCounter(), 0, "Counter should reset to 0 when max limit is exceeded");
}
```

The increment value is deliberately set to exceed MAX_LIMIT, triggering the counter to reset. This test ensures that the contract correctly handles scenarios where the maximum limit is surpassed.

### Invariant Testing
In the simplest terms, an invariant is a condition that should always hold true no matter what state the system is in.

Invariant testing, therefore, involves writing tests to ensure these conditions always remain true throughout the lifetime of the contract.

You should know that this kind of testing is super important in smart contracts development since they often manage digital assets and sensitive transactions.

Invariant testing continuously validates the contract against its fundamental rules, catching anomalies that could indicate deeper issues. This means, that the core rules or truths about your contract would need to be clear and properly defined.

Tools like Echidna (for Ethereum contracts) are used to automate this process. They run the contract with a wide range of inputs and states to ensure the invariants hold true in all scenarios.

#### Echidna
Echidna is a fuzz testing tool specifically designed for Ethereum smart contracts. It generates a wide range of random inputs and feeds them to your contract.

Because of its random input generation, it can find vulnerabilities that might not be obvious or that are only revealed under unusual conditions.

Echidna is relatively straightforward to set up and use, especially if you’re already familiar with Solidity. Writing Echidna tests is often simpler than writing traditional unit tests.

Let’s take a look at what an Echidna test would look like by reusing our SimpleCounter contract.

If you remember, we had the MAX_LIMIT constant defined and this is going to be the invariant that we need to test.


```solidity
function echidna_test_counter_max_limit() public view returns (bool) {
    return counter <= MAX_LIMIT;
}
```

Wait, simple isn’t it? And what does it do you may ask?

Echidna will repeatedly call the increment function with random values and then check if `echidna_test_counter_max_limit` returns true. If Echidna finds a way to make this function return false, it means our contract has a bug.

### Formal Verification
Formal verification is a rigorous mathematical approach to proving the correctness of software. It uses mathematical techniques to prove that a software program meets its formal specification, which is a precise description of what the program is supposed to do.

#### Why is formal verification important for smart contracts?
Formal verification is one of the most effective ways to prove the correctness of smart contracts. DeFi contracts often involve intricate financial algorithms, such as interest rate calculations, yield farming strategies, or liquidity pool balancing. Formal verification mathematically proves that these algorithms work precisely as intended, ensuring there are no logical errors or unintended consequences.

A good example would be how in AMM contracts, formal verification can ensure that the pricing algorithm, liquidity provision, and token-swapping mechanisms are free from flaws that could lead to financial losses.

#### Certora Prover
Certora Prover is the most popular formal verification tool, which is based on SMT (Satisfiability Modulo Theories) solving, which is a powerful technique for proving the correctness of software programs.

SMT solvers can handle a wide variety of theories, including arithmetic, bit-level operations, and data structures. This makes Certora Prover a versatile tool that can be used to verify a wide variety of smart contracts.

Tests written for Certora Prover are written in CVL (Certora Verification Language), a declarative domain-specific language designed for specifying and verifying smart contracts. CVL is based on Hoare triples, which consist of three parts:

- **Precondition:** A condition that must be true before the operation is executed.
- **Operation:** The code that is being verified.
- **Postcondition:** A condition that must be true after the operation has been executed.

Let’s now extend our SimpleCounter contract so that we can add a very simple demonstration of how a test written with Certora Prover looks like.


```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdvancedSimpleCounter {
    uint public counter;

    function increment(uint value) public {
        counter += value;
    }

    function decrement(uint value) public {
        require(counter >= value, "Counter cannot go below zero");
        counter -= value;
    }
}
```

In this contract, decrement decreases the counter by a specified value but ensures that the counter does not go below zero.

And following the structure mentioned above, this is how the tests would look like:

```
pragma cvl;

rule incrementDoesNotOverflow(uint256 value) {
    env e;
    AdvancedSimpleCounter c = new AdvancedSimpleCounter();

    c.increment(value, e);
    assert c.counter >= value;
}

rule decrementDoesNotUnderflow(uint256 value) {
    env e;
    AdvancedSimpleCounter c = new AdvancedSimpleCounter();

    c.increment(value, e);
    uint256 decrementValue = e.chooseUint(value);
    c.decrement(decrementValue, e);
    assert c.counter <= value;
}
```

`incrementDoesNotOverflow`: This rule checks that the counter variable in the AdvancedSimpleCounter contract does not overflow after an increment operation.

`decrementDoesNotUnderflow`: This rule ensures that the counter does not go below zero after a sequence of increment and decrement operations.

To run these CVL tests, you would use the Certora Prover CLI and provide the path to the Solidity contract and the `.spec` file containing the CVL rules.

### Symbolic Execution
Symbolic execution is a method of analyzing a program to determine what inputs cause each part of a program to execute. Instead of running the program with actual input data, it runs the program with ‘symbolic’ inputs (we will elaborate more on that in a moment).

Its unique strength lies in its ability to consider all possible inputs and systematically map every potential execution path of a program, something that fuzz testing, invariant testing, and formal verification don’t inherently do. It’s capable of identifying paths that might be missed by human testers or random input generation.

Symbolic execution uses symbolic values instead of concrete data. This means that instead of executing a program with specific inputs (like x = 5), it uses symbols (like x) that can represent an infinite range of possible values. This allows the analysis to account for every possible input scenario in one go.

#### Manticore
Manticore is a powerful analysis tool primarily used for smart contract and binary program testing. Developed by Trail of Bits, it’s known for its versatility and robustness in security analysis, particularly in the Ethereum blockchain space.

Its customizability offers a significant advantage, allowing users to craft detailed and specific analyses suited to the unique requirements of their code. In other words, it allows users to write custom analysis scripts, making it a flexible tool that can be tailored to suit specific testing and analysis needs.

##### Which language is used to write its tests?
Tests with Manticore are typically written in Python. Manticore itself is implemented in Python and provides a Python API for writing custom analysis scripts.

In a typical Manticore test script:
- You instantiate a Manticore object for either a smart contract or a binary.
- Define the symbolic input variables and state conditions.
- Run the Manticore engine to explore different execution paths.
- Use Python functions to assert conditions, analyze states, or extract information about vulnerabilities or execution paths.

Let’s use our AdvancedSimpleCounter contract from above and create a simple test with Manticore. First, let’s assume our AdvancedSimpleCounter contract is compiled and we have its bytecode:


```
from manticore.ethereum import ManticoreEVM

# Initialize Manticore's EVM object
m = ManticoreEVM()

# User account setup
user_account = m.create_account(balance=1000)

# Contract bytecode (assuming it's compiled)
contract_bytecode = "0x60806040..."  # Replace with actual bytecode

# Define a hypothetical maximum limit for demonstration
MAX_LIMIT = 20

# Deploy the contract
contract = m.create_contract(owner=user_account, 
                             balance=0, 
                             data=contract_bytecode)

# Make a symbolic value for the increment
sym_value = m.make_symbolic_value()

# Execute the increment function with symbolic value
contract.increment(sym_value, caller=user_account)

# Explore all states generated by Manticore
for state in m.ready_states:
    # State-specific analysis: Check if the counter exceeds MAX_LIMIT
    counter_value = state.platform.get_storage_data(contract.address, 0)  # Assuming counter is the first storage variable
    with state as temp_state:  # Temporarily enter the state for analysis
        if temp_state.can_be_true(counter_value > MAX_LIMIT):
            print("Found a state where counter exceeds MAX_LIMIT")
        else:
            print("Counter is within the acceptable range")

# Finalize and store the analysis results
m.finalize()
```

#### Initialize Manticore’s EVM
Creates a new instance of Manticore’s Ethereum Virtual Machine for smart contract analysis.

#### User Account Setup
Sets up a user account with a certain Ether balance to interact with the contract.

#### Contract Bytecode
The compiled bytecode of the AdvancedSimpleCounter contract. In a real scenario, this would be the output from compiling the Solidity code.

#### Deploy the Contract
Uses Manticore to deploy the smart contract on its simulated Ethereum blockchain.

#### Symbolic Value Creation
Creates a symbolic value that represents a range of possible inputs.

#### Execute the Contract Function
Calls the increment function of the contract with the symbolic value.

#### Explore States
Iterates through all the states generated by Manticore during the execution. In each state, you can add analysis logic to check for certain conditions or vulnerabilities.

#### Finalize the Analysis
Stores the analysis results and completes the execution of the script.

### Mutation Testing
Mutation testing is a software testing method that involves deliberately introducing small changes, or mutations, to the source code of a program. These mutations are intended to mimic the types of errors that could occur in real-world code, such as typos, syntax errors, and logic errors.

The goal of mutation testing is to ensure that the program’s test suite is able to detect these mutations and fail the tests. A strong test suite will ‘kill’ these mutations by failing when a change introduces a fault. If a mutation ‘survives’, it indicates a potential weakness in the test coverage.

The big benefit that mutation testing tools bring to the table that other techniques for test coverage don’t is that it doesn’t measure coverage in terms of lines of code tested but it directly measures how well the tests can detect actual faults.

#### And that’s how it helps in identifying specific weaknesses in the test suite, allowing developers to improve test cases and enhance their effectiveness.

#### Here are the key steps involved in mutation testing:

- **Generate mutants:** A mutation testing tool is used to automatically generate a large number of mutants from the original source code. Each mutant represents a potential error that could occur in the code.
- **Execute tests:** The test suite is run against each mutant. If the test suite detects the mutation and causes the test to fail, then the mutant is said to be killed. If the test suite does not detect the mutation, then the mutant is said to be alive.
- **Analyze results:** The results of the mutation testing are analyzed to determine the mutation score. The mutation score is a measure of the effectiveness of the test suite in detecting errors. A high mutation score indicates that the test suite is effective at detecting errors, while a low mutation score indicates that the test suite is not effective at detecting errors.

#### Gambit
Gambit is an open-source mutation generator created by Certora and specifically designed for Solidity.

It works by traversing the Abstract Syntax Tree (AST) of Solidity source code. It identifies potential locations in the source code where mutations (intentional minor changes or faults) can be introduced.

It can be used in conjunction with Certora Prover and the mutants generated by Gambit are verified against the original CVL specifications.

#### Now, how does the process of using Gambit look? Let’s take our AdvancedSimpleCounter as an example and follow what would the steps be:
- **Generating Mutations:** Run Gambit on the contract. Gambit will parse the contract’s AST (Abstract Syntax Tree) and apply mutations to it. These mutations might include changing arithmetic operations, altering logical conditions, or modifying the control flow.
- **Reviewing Mutated Code:** Gambit will output mutated versions of your original contract. Each of these versions will have slight modifications intended to mimic common programming errors or logical oversights.
- **Formal Verification with Certora Prover:** You would then use Certora Prover to verify both the original and mutated contracts against your CVL specifications. For instance, you might have a specification ensuring the counter never becomes negative.
- **Analyzing the Results:** The outcome will show you which mutations were ‘killed’ (i.e., caught by the specifications) and which survived. Surviving mutations indicate potential weaknesses in your specifications or areas of the contract not adequately covered.
- **Refining Specifications or Contract Logic:** Based on this analysis, you can refine your CVL specifications to cover more potential issues or reconsider aspects of your contract logic.

#### A bonus tool for mutation testing…

##### Slitherin
Slitherin by Pessimistic is primarily a tool for mutation testing, specifically designed for Solidity smart contracts. While it extends the capabilities of Slither, which is a static analysis tool, Slitherin’s unique contribution lies in its approach to generating mutations in the smart contract code to enhance the process of testing and verification.

The aim is to increase the sensitivity of detectors to assist you, resulting in more frequent detection of potential false positives (FPs) compared to the original Slither detectors.

Slitherin can be used alongside formal verification tools like Certora Prover, providing a means to evaluate and possibly improve formal specifications for smart contracts.

It is accompanied by a user-friendly interface for visualizing the results of the mutation analysis, making it easier to interpret the outcomes and improve specifications based on the findings.

### Wrapping up
Systematic and thorough testing is a necessity. In this ever-evolving landscape, where the stakes are high and the threats are constantly shifting, the integration of robust security measures into every stage of a dApp’s development cycle is vital for the health of your application.
