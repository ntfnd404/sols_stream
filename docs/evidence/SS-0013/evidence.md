# SS-0013 Verification Evidence

Status: Passed

## Source Snapshot

- Signaling read boundary:
  `ac13b09a1bada8bb564c27efbfdc0c7d7cc25c0c`.
- Wallet read boundary:
  `5904676eeda043fc1a34e54c82c6e939c7346ae3`.
- Typed app diagnostics:
  `aaeea7f7252d87279ed659cfe68e15bc10c4d22b`.
- Verified source commit: `e8003534af0585e3431819f99bcc88dd4952cf45`.
- Verified source tree: `dcc466554611c72a40c18db6a291f2f09f1114cb`.
- Lockfile hash: `cda66e363ca990577c574afb6c842697422bb47a`.

## Scope

This evidence covers local analyzers, unit tests, package integration tests and
generated SDK drift. Network IDL synchronization, validator/devnet, broker,
browser, and application E2E belong to separate release tickets.

## Environment

- Dart SDK: `3.12.2` stable, macOS arm64.
- Flutter: `3.44.6` stable.
- Host platform proven by the verifier output: macOS arm64. The verifier did
  not record a macOS product version, so this evidence does not invent one.

## Commands And Results

From the repository root, the tracked verifier
`tool/quality/verify_staged.sh` completed successfully against the source tree
identified above. It was invoked through the then-local `make verify-staged`
wrapper. The verifier ran locked dependency resolution, analyzers and tests for
`signaling`, `signaling_solana`, and `solana_wallet`, application analysis and
tests, architecture tests, generated SDK drift verification, and staged diff
validation.

Network IDL synchronization, validator/devnet flow, broker contracts, browser
tests, and application E2E are outside SS-0013 scope. They are owned by the
separate release tickets linked from the project roadmap and are not reported
as skipped SS-0013 checks.

## Acceptance Matrix

| Scenario | Evidence | Result |
|---|---|---|
| Whitelisted availability failures remain transient | classifier tests | Passed |
| Unknown provider failures become sanitized terminal failures | classifier tests | Passed |
| Provider payload is absent from public failures | boundary tests | Passed |
| Release diagnostics omit error and stack rendering | app security tests | Passed |
| Programming `Error` is not translated | boundary tests | Passed |
| Account integrity and structured transaction behavior remain unchanged | package regression suites | Passed |
