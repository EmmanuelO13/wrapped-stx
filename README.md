A Clarity smart contract that implements a **wrapped version of STX**, following the [SIP-010 fungible token standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md). Users can **wrap native STX tokens 1:1 into wSTX**, a fungible token usable in DeFi protocols or other Clarity contracts.

---

## Contract Overview

- **Token Name:** Wrapped STX
- **Token Symbol:** wSTX
- **Decimals:** 6
- **Standard:** SIP-010
- **Wrap Ratio:** 1 STX = 1 wSTX

This contract allows users to:
- Wrap native STX into wSTX via `wrap`
- Transfer and approve wSTX tokens per SIP-010
- Query balances, allowances, and metadata

>  `unwrap` is **not yet implemented**. Only wrapping is currently supported.

---

## Getting Started

---

##  Contract Functions

###  SIP-010 Read-Only Interfaces

| Function            | Description                         |
|---------------------|-------------------------------------|
| `get-name`          | Returns token name (`Wrapped STX`)  |
| `get-symbol`        | Returns token symbol (`wSTX`)       |
| `get-decimals`      | Returns token decimals (`6`)        |
| `get-total-supply`  | Returns total supply of wSTX        |
| `get-balance`       | Returns token balance of a principal |
| `get-allowance`     | Returns allowance from owner to spender |

---

###  Core Token Logic

| Function         | Type      | Description                                          |
|------------------|-----------|------------------------------------------------------|
| `wrap`           | public    | Converts transferred STX into wSTX (1:1)            |
| `transfer`       | public    | Transfers wSTX between addresses                    |
| `approve`        | public    | Approves spender to use a set amount of tokens     |
| `transfer-from`  | public    | Transfers tokens using allowance (spender role)    |

---

##  Example Usage

### Wrap STX

```
(contract-call? .wrapped-stx wrap)
;; Send STX with this call via post conditions or wallet
```
Transfer Tokens
```
(contract-call? .wrapped-stx transfer 'SP...recipient u1000000)
```
Approve & Transfer From
```
;; Owner approves spender
(contract-call? .wrapped-stx approve 'SP...spender u500000)
```

;; Spender calls:
(contract-call? .wrapped-stx transfer-from 'SP...owner 'SP...recipient u500000)
 Data Structures
Data Variables
`total-supply`: Tracks total minted wSTX

`balances`: User balances

`allowances`: Mapping of approved amounts for `transfer-from`

Error Codes
Code	Description
`u100`	Insufficient STX (wrap)
`u101`	Insufficient wSTX (transfer)
`u102`	Unauthorized access
`u103`	Zero amount error

 Roadmap
 Add `unwrap` function to redeem wSTX for STX

 Add events (e.g., `ft-transfer`, `ft-mint`, `ft-burn`)

 Improve STX detection on `wrap`

 Audit and gas optimization

