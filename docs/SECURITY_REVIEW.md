# Security review (author analysis, not an independent audit)

Scope: `src/Router.sol`, native-asset adapter/recipient interactions, Solidity 0.8.28. Educational fixture only. No production funds, private keys or network ownership.

| Threat | Implemented control | Adversarial evidence | Residual risk |
| --- | --- | --- | --- |
| Unauthorized adapter governance | Immutable owner | `testAccessControl` | Owner key compromise; centralized policy |
| Unapproved adapter | Explicit allowlist | `testUnapprovedAdapter` | Approved malicious adapter can steal input if policy is poor |
| Reentrant adapter | Locked effect boundary | `testReentrancyRejected`, verifies exact error selector | No claim of exhaustive attack coverage |
| Poor output execution | Actual native balance delta + minimum | slippage fuzz; rollback test | No oracle/MEV protection; caller selects minOut |
| Replay | Chain/router/caller/nonce domain + consumed flag | replay + chain/caller separation tests | No cross-chain message delivery or finality |
| Rejected recipient | Revert entire transaction | recipient rollback test | Recipient can deny its own execution |
| Existing donation masks loss | Exclude baseline balance | donation test | Forced/ordinary donations can remain trapped |
| Loss of local conservation | Fixture handler invariant | 128 runs × 32 depth; 4,096 calls | Trusted rate-1 fixture is narrower than arbitrary adapters |

Status: controls implemented; outcomes recorded by exact-commit receipts. Open scope includes ERC20 fee/rebase/approval behaviors, cross-chain replay semantics, bridge trust, finality, upgradeability and professional independent security review. No CVE, audit certification, mainnet history or Yul expertise is claimed.
