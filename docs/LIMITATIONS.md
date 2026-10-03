# Limitations and unsupported claims

Native-asset local fixture only: no ERC20 quirks, oracle, MEV mitigation, bridge messaging/finality/relayer verification, Yul/assembly, upgrade safety, mainnet/testnet operations, real multi-network deployment, or independent audit. Owner can allow a malicious adapter; user must trust the allowlist policy. Forced donations may remain stuck. Public receive accepts donations. Gas depends on compiler/profile and fixture. The two invariant predicates are grouped by Foundry 1.8.4 into one reported campaign.

Tests exercise fixtures, not production traffic. Measurements include environment and exact commit in the receipt. A failure outcome is distinct from an unmeasured property. No years of experience, degrees, CVEs, production scale, mainnet ownership or independent audit are claimed.
