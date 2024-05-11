# Curiosity in Solana #2

Today we want to share some insights about managing errors by comparing Solana programs to Solidity contracts:

🟣 **Solidity and the require statement:**
In Solidity, using require abruptly halts contract execution. If the condition fails, a revert is executed, which nullifies any subsequent operations and reverts the state changes.

**Consequence:**
Stops everything. No further action is taken beyond the error.

🟣 **Solana and the require! macro:**
Unlike Solidity, Solana uses the require! macro to check conditions, but it does not stop program execution if there's an error. It simply returns a different value to indicate a failure.

**Consequence:**
Execution continues, requiring the program to explicitly handle the error by returning a Result value.

🟣 **What you get by using Solana:**
Flexibility and total control for developers on how to handle errors. This allows for the implementation of customized logic in case of failure.

🟣 **Worth considering:**
With great power comes great responsibility. This flexibility means that the developer must be meticulous in managing all possible error conditions.

Understanding these differences is crucial for developing robust and secure smart contracts/programs on both platforms.

We hope you found this interesting, stay tuned for more posts like this.


<img width="606" alt="image" src="image/Solana_2.png">
