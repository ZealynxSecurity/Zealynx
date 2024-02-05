## [Autonolas](https://github.com/scab24/Autonolas)


# Installation

To be able to use this repository, you need to have the following installed:

- Foundry
 -  https://book.getfoundry.sh/getting-started/installation
- Halmos
 -  https://github.com/a16z/halmos/tree/main
- Echidna
 -   https://github.com/crytic/echidna?tab=readme-ov-file#installation
- Medusa
 - https://github.com/crytic/medusa?tab=readme-ov-file#installation
- Ityfuzz
 - https://docs.ityfuzz.rs/installation-and-building
- Blazo
 - https://github.com/fuzzland/blazo

# Init:

```js
 git submodule update --init --recursive
```
```js
sudo forge build -force
```

  
# Tools used:


## Foundry

### Explanation
We have been conducting fuzzing tests and invariant tests to verify the proper functionality of the contract.

### - OLASTest

```
forge test --mc OLASTest
```

<img width="433" alt="image" src="image/1.png">

### - veOLASTest

```
forge test --mc veOLASTest
```
<img width="355" alt="image" src="image/2.png">


##  Halmos 


To successfully run the tests, it is necessary to have Foundry and Halmos installed.
In these contracts, we have employed fuzzing techniques combined with formal verification in order to conduct a much more exhaustive and higher-quality analysis, leveraging their significant advantages over using just a fuzzer.

### - HalmosOLAS

### Explanation

In this contract, we have utilized:

- A contract as the foundation for the tests, employing cheatcodes provided by Halmos to create users and random amounts distributed among them in a hierarchical structure.

- A second contract in which we have written all the test logic for the code we have tested:

  ```
  halmos --contract HalmosOLAS --solver-timeout-assertion 0
  ```

  <img width="585" alt="image" src="image/3.png">
   


### - HalmosveOLAS

### Explanation

In this contract, we have utilized:

- A contract as the foundation for the tests, employing cheatcodes provided by Halmos to create users and random amounts distributed among them in a hierarchical structure.

```
sudo halmos --contract HalmosveOLAS --solver-timeout-assertion 0
```

- A second contract in which we have written all the test logic for the code we have tested:
<img width="456" alt="image" src="image/4.png">


## Echidna

### - EchidnaOLAS

```
echidna src/Echidna/EchidnaOLAS.sol --contract EchidnaOLAS
echidna . --contract EchidnaOLAS
```

<img width="606" alt="image" src="image/5.png">


### - EchidnaOLASAssert

```
echidna src/Echidna/EchidnaOLASAssert.sol --contract EchidnaOLASAssert --test-mode assertion
echidna . --contract EchidnaOLASAssert --test-mode assertion
```

<img width="603" alt="image" src="image/6.png">


### - EchidnaVeOLASAssert

```
echidna src/Echidna/EchidnaVeOLASAssert.sol --contract EchidnaVeOLASAssert --test-mode assertion
echidna . --contract EchidnaVeOLASAssert --test-mode assertion
```

<img width="606" alt="image" src="image/7.png">



## Medusa

### EchidnaOLASAssert

<img width="350" alt="image" src="image/8.png">



```
medusa fuzz
```

<img width="425" alt="image" src="image/9.png">



### EchidnaVeOLASAssert

<img width="317" alt="image" src="image/10.png">


```
medusa fuzz
```

<img width="544" alt="image" src="image/11.png">



## Ityfuzz

### Explanation

ItyFuzz is a blazing-fast EVM and MoveVM smart contract hybrid fuzzer that combines symbolic execution and fuzzing to find bugs in smart contracts offchain and onchain.

We have utilized the ityfuzz tool in various ways:
- One approach involved using the "bug()" keyword to intentionally break specific invariants within the code at particular locations.
- Another method was to integrate it within the existing assert tests of Echidna since the tool itself operates within it, aiming to enhance its capabilities by applying formal verification within the Echidna fuzzer.

<img width="575" alt="image" src="image/12.png">


```
sudo blazo contest2
```
```
ityfuzz evm --builder-artifacts-file './results.json' --offchain-config-file './tt.json' -t "a" -f
```


<img alt="image" src="image/13.webp">


