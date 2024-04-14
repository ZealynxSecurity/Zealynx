# How to Efficiently Prepare for a Productive Smart Contract Audit

_Bloqarl_  

_9 min read_  
_Sep 13, 2023_  

You and your team have finally decided to send your project and smart contracts for a security review. Some of you may have even had to work hard to convince the decision-makers in your company of its necessity.

Now, not only do you want to choose the right company with trusted professionals (like us at Zealynx), but you also want to ensure that your smart contracts are as prepared as possible for the security review.

### What does it mean to have your project ready and why is it important?

Do you realize how much time you’ve spent planning, discussing, implementing, and fine-tuning the features of your project? Well, the security reviewers who will review your code haven’t.

Your developers might have had a few sessions with a product team, plus many more hours of discussion while implementing the code. So, your goal now is to pass on your project to the auditor’s firm, so that they need as little time as possible to understand what to expect from the code and to have the cleanest and most readable code.

### CONTENT

#### Overview & Documentation
- Protocol concepts and workflows
- Contract Overview
- Identify invariants
- Libraries used
- NatSpec & comments

#### Development & Good Practices
- Common Solidity best practices
- Testing

#### Internal Security Review
- Solidity patterns
- Security considerations

#### Security Review Scope
- Known issues
- Concerns

#### Getting Started
- Readme
- Requirements
- Quick start

## Overview & Documentation

### Protocol Concepts and Workflows
One of the initial pieces of information the security reviewer will need is an understanding of the protocol’s type, goals, and functionalities.

Drawing from our experience in analyzing DeFi protocols and participating in public contests, we have encountered some intriguing methods for presenting the key features that have been implemented.

One approach, frequently observed in larger protocols, involves including a dedicated section for explaining concepts, features, or functionalities.

A second approach, often utilized in the case of smaller protocols or security reviews with narrower scopes, is to provide expected workflows for their primary functionalities.

We recently came across this approach during our participation in the first contest with CodeHawks.

### Contract Overview
In the contract overview, you have the flexibility to provide as much or as little information as you consider necessary. Naturally, the more information you furnish, the less time the security reviewer will need to spend on research and data collection during the process.

The concept is to include the names of the smart contracts within the scope and to mention and/or explain their roles in the primary functionalities of the protocol. Additionally, it would be beneficial to provide explanations for some of the key functions within the contract itself.

Main protocols like Uniswap or Aave provide such contract overviews in their documentation.

If you’re looking to elevate your approach, consider hiring a technical writer or enlisting someone with strong writing skills from your team to create a comprehensive breakdown of the Smart Contracts within the scope of the security review.

Good examples are these two articles that one of our team members at Zealynx wrote for Gravita and Spiral DAO.

### Identify Invariants
Invariants are conditions that must always be true under a certain set of well-defined assumptions.

For instance:
- The total supply of an ERC20 token does not change unless mint or burn is called.
- The sum of all balances in the contract should equal the total supply.
- Each wallet can have a max of 100 tickets.
- The window for minting tickets is 72 hours.

Supplying this information holds immense value. When you provide this data, you are furnishing the security reviewer with highly specific requirements that must hold true without exception.

This information aids in testing and facilitates the use of tools available to security reviewers for attempting to uncover vulnerabilities in the code, such as Fuzz testing and formal verification tools.

### Libraries Used
There are numerous reasons to incorporate existing, well-established, and thoroughly tested libraries into your smart contracts. However, we won’t delve into those details at this time.

An excellent location to specify the libraries utilized by your contracts is within the contract overview mentioned earlier.

This practice aids in comprehending the code and references employed within the contract itself, facilitating familiarity with the codebase.

### NatSpec & Comments
Overall, developers should strive for clean code and comprehensive naming conventions for contracts, functions, variables, and so on. However, providing additional details in the code can significantly facilitate the security reviewer’s work.

There are two things to keep in mind to use:
- **NatSpec:** When we come across a smart contract with a verbose NatSpec on top of its contract and functions, as a security reviewer, it makes it much easier to understand what we should expect to find in the code itself.
- **Inline comments:** If you have a piece of code in Yul or any logic that you believe might be complex, adding inline comments to explain what that piece of code is intended to achieve will assist the security reviewer in verifying it.

## Development & Good Practices
### Common Solidity Best Practices
As is the case with any programming language, Solidity has its own set of best practices that can greatly assist security reviewers during contract reviews.

We’d like to emphasize some crucial practices and also provide a list of frequently reported non-critical issues. These can significantly enhance your code’s quality and free up time for the security reviewers to concentrate on more pertinent sections of the code.

First and foremost, maintaining a well-defined structure in your contracts is of paramount importance. Everything should have its designated place within a contract.

The Solidity documentation offers a comprehensive Code Layout section with in-depth details, and it is highly recommended to read it to become familiar with the recommended structure.

Within the code layout section, we would like to emphasize and expand upon the recommended order for arranging all elements within a contract:

```
Pragma statements


Import statements
Interfaces
Libraries
Contracts

State variables

Events

Function Modifiers
Struct, Arrays or Enums

Constructor

Fallback — Receive function
External visible functions
Public visible functions
Internal visible functions
Private visible functions
```

An excellent complement to understanding and adhering to this structure is to “declare” it within the code by adding a comment as a header before introducing a new section of elements.

```
// EXTERNAL FUNCTIONS
[...]

// PUBLIC FUNCTIONS
[...]

// INTERNAL FUNCTIONS
[...]
```

Frequently, we encounter extensive lists of non-critical or informational issues reported during public contests, and a significant number of them tend to be repetitive.

Therefore, here is a list of some of those issues that you should ensure are addressed in your contracts before submitting them for a security review:

- "Public functions not called by the contract should be declared external instead."
- "Constants should be defined rather than using magic numbers."
- "Custom errors should be used rather than revert()/require()."
- "Addresses shouldn't be hard-coded."
- "Variables don’t need to be initialized to zero."
- "Non-external/public function names should begin with an underscore."
- "Names of private/internal state variables should be prefixed with an underscore."
- "Avoid using floating pragma."
- "Consider moving msg.sender checks to modifiers."
- "Named mappings are recommended."

### Testing
Add tests as if there’s no tomorrow—as if your life (or money) depends on it.

Commonly, issues arise when testing a portion of the code that developers haven’t tested. That’s why it’s essential to test every function you add.

Other types of testing, such as fuzz tests, invariant testing, and formal verification, may potentially be conducted by the auditor’s firm. Nevertheless, it’s beneficial to be aware of their existence.

## Internal Security Review
Before sending your project for a security review, it’s crucial to understand one thing: whether you send it to a solo auditor or an auditor’s firm, it can’t guarantee that your code is entirely bug-free.

In an ideal scenario, the more individuals reviewing the contracts, especially at various stages, the higher the likelihood of making the code more secure.

This is where we want to emphasize the value of solo auditors or small auditor firms (typically consisting of 2–4 security reviewers).

Whether as a part of your team or hired as a contractor, having someone with Web3 security knowledge review the code as the initial stage of the security review process is of paramount importance.

Such an individual or team may be able to identify critical issues at an early stage. Therefore, please consider incorporating this step into your process.

### Solidity Patterns
The Solidity programming language is still in its early stages. Nevertheless, a few recommended patterns have been identified for applying when developing your smart contracts.

Let us highlight some of these patterns, but be sure to become familiar with them from the source.

- **Withdrawal from Contracts:** The recommended method of sending funds after an effect is using the withdrawal pattern.
- **Restricting Access:** You can never restrict any human or computer from reading the content of your transactions or your contract’s state, but you can make it a bit harder by using encryption.
- **State Machine:** Contracts often act as state machines, which means that they have certain stages in which they behave differently or in which different functions can be called.
- **Check Effects Interactions:** Reduce the attack surface for malicious contracts trying to hijack control flow after an external call and avoid reentrancy attacks.
- **Proxy Delegate:** Introduce the possibility of upgrading smart contracts without breaking any dependencies.
- **Eternal Storage:** Because the old contract is not actually updated to a new version, the accumulated storage still resides at the old address.

### Security Considerations
As a developer, it is crucial that you are capable of implementing code while being aware of the potential security issues that are frequently introduced, enabling you to avoid them.

As mentioned earlier, we are collecting some issues to enable you to delve deeper into the provided source.

- Private Information and Randomness.
- Reentrancy.
- Gas Limit and Loops.
- Sending and Receiving ETH.
- Call Stack Depth.
- Authorized Proxies.
- tx.origin
- Two’s Complement / Underflows / Overflows
- Clearing Mappings.

## Security Review Scope
Now that you have prepared your code and followed all the recommendations above, it’s time to start preparing the documentation for the security review itself.

Begin by ensuring that you communicate to the solo auditor or the team which of the smart contracts in the project you want them to focus on for review and bug reporting.

However, this doesn’t imply that these are the only files you should share with them. Ideally, you should provide all relevant and necessary files, or even the entire project, to give the security reviewers as much context as possible.

### Known Issues
It’s possible that you’ve identified certain issues either during your own internal security review or a previous audit.

In such cases, it’s time-saving to list these issues in the provided documents. This ensures that security reviewers are aware of them and won’t need to spend time searching for and reporting them.

### Concerns
In the Web3 development world and blockchain, things are continually evolving. This means you might have some gaps in your knowledge, as well as concerns, questions, or fears, especially if a significant amount of money is at stake due to the feature you’ve implemented.

Sharing these concerns with the security reviewers can be highly beneficial. Security reviewers strive to think like hackers, so your insights can steer them in the right direction as they seek to identify vulnerabilities.

## Getting Started
### Readme
This might seem obvious, but be sure to include a Readme.md file in your framework. This file should contain essential information and any mandatory requirements necessary to ensure your project can compile and run on another person’s machine.

### Requirements
Are there any dependencies integrated into your project?
Are you using a specific testing framework?
Is there a specific reason for using a particular version of any tool?
Please document and share this information.

### Quick Start
You have been working on the project on your own machine for some time, so you may have encountered various compiler issues, installed dependencies, or tools.
Before submitting the project for a security review, ensure that you can successfully compile and run it on a different machine. Save the commands used for this purpose so that you can share them in the Getting Started section of your Readme.md file.
