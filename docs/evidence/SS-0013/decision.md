# SS-0013 — Provider Error Boundary

## Decision

Provider exception objects and messages do not cross Solana read or wallet
balance boundaries and are never passed to app-wide reporters.

- Explicit timeout/connectivity/availability failures remain transient.
- Other signaling RPC exceptions become `SignalingReadFailureException`.
- Wallet balance RPC exceptions become `SolanaWalletReadException`.
- Programming `Error` values are not translated by these boundaries.
- App diagnostics use closed stable contexts and never render an unknown
  exception with `toString()`.
- Debug/profile diagnostics may include runtime type and stack. Release
  diagnostics contain only a stable context code and label.

## Non-goals

No retry-policy, account-semantics, transaction, funding, wire-format, crypto,
or E2E change belongs to SS-0013.

## Acceptance

- Provider endpoint, body, message, address, and object are not copied from
  failures into public exceptions or error diagnostics. Separately configured
  service URLs follow the environment-diagnostics policy.
- Existing transient reads remain retryable; terminal reads do not.
- Account integrity and programming failures retain their own contracts.
- Structured transaction failures remain unchanged.
