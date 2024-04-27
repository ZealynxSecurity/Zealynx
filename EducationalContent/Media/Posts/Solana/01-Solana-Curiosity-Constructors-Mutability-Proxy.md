# 🔍 Curiosity in Solana #1

Today we want to share some curiosities about programming smart contracts on Solana compared to Solidity, focusing on three aspects:

- 🎯 constructors, mutability, and proxy usage.

## 1️⃣ Constructor vs. Initialize
Unlike Solidity, Solana does not use a traditional constructor, but an **initialize** method. This is similar to what happens in Solidity when using proxies, but with a significant advantage: contracts on Solana are updatable by default, eliminating the need for an external proxy.

### 🤔 What does this mean?
It means that contracts on Solana can be updated directly, without the need for proxies like in Solidity. This facilitates and speeds up updates, making the process simpler and more efficient.

### ✅ Pros: Simplification and efficiency in updates
You don't need to write a proxy to update your contracts. Additionally, Solana does away with `delegatecall`, a common function in Solidity used primarily to enable contract updates through a proxy contract. In Solana, as the bytecode of a program can be updated directly, there is no need to resort to `delegatecall` to invoke new implementation contracts.

We hope you found this interesting, stay tuned for more posts like this.
