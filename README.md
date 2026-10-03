# Solidity Multichain Security Lab

Test native-asset routing boundaries: approved adapters, replay domains, slippage and reentrancy.

[![CI](https://github.com/afimeth/solidity-multichain-security-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/afimeth/solidity-multichain-security-lab/actions)

## Run, test and demo

```sh
forge test -vv
forge snapshot
forge test --gas-report
forge script script/Deploy.s.sol:Deploy
python scripts/verify.py
```

Install Python 3.11+ for the evidence harness. Install Foundry 1.8.4 (Solidity 0.8.28). External paid services are not required.

## Implemented

Solidity 0.8.28 native-asset router, immutable owner adapter allowlist, chain/address/caller/nonce request domain, balance-delta minimum output, deadline checks, checks/effects + reentrancy lock, local deployment guard, fuzz and handler invariants, gas snapshot.

## Evidence and status

- **IMPLEMENTED:** runnable code and failure tests in this repository.
- **MEASURED:** [baseline](evidence/baseline.json) identifies the measured source commit. Each CI matrix job uploads a fresh `receipt.json` for its exact `GITHUB_SHA`, with actual test totals and toolchain. A receipt commit does not rewrite the measured source SHA.
- **DESIGNED:** Real bridge/router integration and security review by an independent reviewer remain open.
- **NOT CLAIMED:** Native-asset local fixture only: no ERC20 quirks, oracle, MEV mitigation, bridge messaging/finality/relayer verification, Yul/assembly, upgrade safety, mainnet/testnet operations, real multi-network deployment, or independent audit. Owner can allow a malicious adapter; user must trust the allowlist policy. Forced donations may remain stuck. Public receive accepts donations. Gas depends on compiler/profile and fixture. The two invariant predicates are grouped by Foundry 1.8.4 into one reported campaign.

Run `python scripts/verify.py` to regenerate ignored local receipts. Benchmark/gas/bundle reports are local measurements, not a production SLO. CI and local runs are separate evidence. Passing tests are not an independent review or an accepted production release.

## Safe CV claim

> Built a local Foundry routing-security lab with access-control, replay-domain, slippage and reentrancy tests, fuzz cases, conservation invariants, and gas measurements.

This describes a laboratory project. It does not establish years of experience, a degree, production scale, employer history, CVEs, mainnet ownership, or independent audit credentials.

## Design and interview walkthrough

See [architecture](docs/ARCHITECTURE.md), [limitations](docs/LIMITATIONS.md), and [interview scenarios](docs/INTERVIEW_SCENARIOS.md). All inputs are synthetic. This is a fresh AI-assisted standalone implementation from public requirements; no private source, customer data, credentials or proprietary code was copied. MIT license applies to this lab.
