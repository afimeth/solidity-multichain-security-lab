# Interview scenarios

These are inferred practice scenarios from a role family, not leaked or confirmed employer questions.

Review a router threat model; test a malicious adapter and rejecting recipient; fuzz output conservation; separate caller and chain replay domains; explain trusted-adapter and bridge limitations.

## Suggested 15-minute walkthrough

1. Explain the concrete user/system problem and failure boundary.
2. Run the demo and one successful path.
3. Run the adversarial suite and explain one rejected path.
4. Discuss the tradeoffs and the unsupported claims.
5. Modify one requirement live and identify what new test/evidence it needs.

## Evidence path

The README describes run commands. `scripts/verify.py` produces exact-commit receipts and actual test totals; CI artifacts add platform coverage.
