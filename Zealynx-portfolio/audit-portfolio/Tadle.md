# Index

| Nº | Title                                                                 | Sections                                                                                     |
|-----|-----------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| 1   | [Incorrect Authority Check in DeliveryPlace Contract](#incorrect-authority-check-in-deliveryplace-contract) | - [Description](#description)<br>- [Impact](#impact)<br>- [Mitigation](#mitigation)        |
| 2   | [Referral Update Function Inadvertently Allows Creation of New Referrals](#referral-update-function-inadvertently-allows-creation-of-new-referrals) | - [Summary](#summary)<br>- [Vulnerability Details](#vulnerability-details)<br>- [Impact](#impact)<br>- [Tools Used](#tools-used)<br>- [Recommendations](#recommendations) |

---


# About the Project

Tadle is a cutting-edge pre-market infrastructure designed to unlock illiquid assets in the crypto pre-market.

Our first product, the Points Marketplace, empowers projects to unlock the liquidity and value of points systems before conducting the Token Generation Event (TGE). By facilitating seamless trading and providing a secure, trustless environment, Tadle ensures that your community can engage with your tokens and points dynamically and efficiently.

<p align="center">
    <img width="300" alt="image" src="image/tadle.png">
</p>



# [Incorrect Authority Check in DeliveryPlace Contract](https://codehawks.cyfrin.io/c/2024-08-tadle/s/1099)

## Description

In the DeliveryPlace contract, there is an important inconsistency between the documented behavior and the actual implementation of authority checks in the `settleAskTaker` function.

```solidity
if (_msgSender() != offerInfo.authority) {
    revert Errors.Unauthorized();
}
```

- The comment states: "caller must be stock authority"
- The implementation checks for offer authority

This discrepancy suggests that the implemented authority checks may not align with the intended access control design. The presence of correct stock authority checks in other parts of the contract further indicates that these functions may be incorrectly implemented.

## Impact

The potential impacts of this vulnerability include:

1. Unauthorized Access: Incorrect authority checks could allow unauthorized parties to settle ask takers or makers, potentially manipulating the market or causing financial losses.
2. Inconsistent Behavior: The discrepancy between different functions' authority checks could lead to unpredictable and inconsistent contract behavior.

## Mitigation

To address this vulnerability, we recommend the following steps:

1. For `settleAskTaker`:
Change the authority check to use `stockInfo.authority`:


===


# [Referral update function inadvertently allows creation of new referrals](https://codehawks.cyfrin.io/c/2024-08-tadle/s/1125)

## Summary

The `updateReferrerInfo` function in the `SystemConfig` contract unintentionally allows the creation of new referrals in addition to updating existing ones. This can lead to unexpected behaviors and data integrity issues.

## Vulnerability Details

The `updateReferrerInfo` function doesn't verify if the referral already exists before updating the information. If called with a non-existent referral address, it creates a new entry in the map.

```solidity
function updateReferrerInfo(
    address _referrer,
    uint256 _referrerRate,
    uint256 _authorityRate
) external {
    // ...

    ReferralInfo storage referralInfo = referralInfoMap[_referrer];
    referralInfo.referrer = _referrer;
    referralInfo.referrerRate = _referrerRate;
    referralInfo.authorityRate = _authorityRate;

    // ... 
}
```

## Impact

1. Security: Malicious users could create unauthorized referral relationships.
2. Data Integrity: May create unintended or invalid referral records.
3. Business Logic: May interfere with the intended referral system logic, potentially affecting reward distribution.

## Tools Used

Manual code analysis.

## Recommendations

1. Modify the `updateReferrerInfo` function to prevent creation of new referrals:

   * Add a check to ensure the referral exists before updating.
   * If the referral doesn't exist, the function should revert.
2. Create a separate function for adding new referrals, if needed.
3. Implement proper access controls for both update and creation functions.
4. Update code documentation to clearly reflect the purpose and behavior of each function.


