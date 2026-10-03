# Architecture

Approved adapter receives native input and sends native output back. Router measures balance delta excluding preexisting balance, checks minOut, then pays recipient. Reverts restore nonce and funds. Handler exercises local swaps and checks conservation/no router residue. Chain-ID variation proves request-domain separation; it does not send cross-chain messages.

## Tradeoff

The lab optimizes local reproducibility and an inspectable failure boundary. The architecture is intentionally small enough to explain during an interview.

## Evidence boundaries

Real bridge/router integration and security review by an independent reviewer remain open.
