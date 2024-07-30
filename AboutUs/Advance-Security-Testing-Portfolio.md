# Advanced Security Testing

Here's our Fuzzing and Formal Verification [Testing Campaign Portfolio](https://github.com/ZealynxSecurity/Zealynx/blob/main/Zealynx-portfolio/Fuzzing-FormalVerification-portfolio.md)

Take a look to the testing tools we use and how we use them:
- [Formal Verification](https://github.com/ZealynxSecurity/Zealynx/blob/main/AboutUs/Our-Formal-Verification-Service.md)
- [Invariant tests](https://github.com/ZealynxSecurity/Zealynx/blob/main/AboutUs/Invariant-tests-with-Echidna.md)

Why do we need Fuzzing and Formal Verification to improve the security reviews? 
[Read this](https://github.com/ZealynxSecurity/Zealynx/blob/main/AboutUs/Why-you-need-Fuzzing-FV.md)

# Our Work

### Possum Labs: Stake yield-bearing assets

- Fuzzing: [Foundry](https://github.com/ZealynxSecurity/Possum-Labs/tree/main/test/V2MultiAsset/Foundry)
- Invariant testing: [Echidna/Medusa](https://github.com/ZealynxSecurity/Possum-Labs/tree/main/src/V2MultiAsset/Echidna) 
- Formal Verification: [Halmos](https://github.com/ZealynxSecurity/Possum-Labs/tree/main/test/V2MultiAsset/Halmos), [ItyFuzz](https://github.com/ZealynxSecurity/Possum-Labs/tree/main/test/V2MultiAsset/Ityfuzz)

### Glif: Liquidity Mining

- Fuzzing: [Foundry](https://github.com/ZealynxSecurity/Glif_LiquidityMinerLP/blob/main/test/Fuzz/FuzzLiquidityMine.t.sol)
- Invariant testing: [Echidna/Medusa]()
- Formal Verification: [Halmos](https://github.com/ZealynxSecurity/Glif_LiquidityMinerLP/blob/main/test/FormalVerification/HalmosFV.t.sol), [Kontrol](https://github.com/ZealynxSecurity/Glif_LiquidityMinerLP/blob/main/test/FormalVerification/KontrolFV.t.sol), [ItyFuzz](https://github.com/ZealynxSecurity/Glif_LiquidityMinerLP/blob/main/test/Fuzz/ItyfuzzInvariant.t.sol)

### Wedefin: Decentralized Index Fund

- Fuzzing: [Foundry](https://github.com/ZealynxSecurity/Wedefin/tree/main/test/fuzz)
- Formal Verification: [Halmos](https://github.com/ZealynxSecurity/Wedefin/tree/main/test/FV)

### Revert: AMM Liquidity Providers

- Formal Verification: [Kontrol](https://github.com/ZealynxSecurity/Revert-Protocol/tree/main/test/FormalVerification/Kontrol), [ItyFuzz](https://github.com/ZealynxSecurity/Revert-Protocol/tree/main/test/FormalVerification/Ityfuzz)

### Bastion Wallet: ERC-4337, Account Abstraction SDK
- Fuzzing: [Foundry-1](https://github.com/ZealynxSecurity/BastionWallet/tree/main/test/Initiator/Foundry/Fuzz), [Foundry-2](https://github.com/ZealynxSecurity/BastionWallet/tree/main/test/SubExecutor/Foundry/Fuzz)
- Invariant testing: [Echidna/Medusa](https://github.com/ZealynxSecurity/BastionWallet/tree/main/src/echidna) 
- Formal Verification: [Halmos-1](https://github.com/ZealynxSecurity/BastionWallet/tree/main/test/Initiator/Halmos), [Halmos-2](https://github.com/ZealynxSecurity/BastionWallet/tree/main/test/SubExecutor/Halmos/Fuzz)

