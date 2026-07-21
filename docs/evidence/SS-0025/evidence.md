# SS-0025 Verification Evidence

Status: Passed

## Source Snapshot

- Verified source tree: `c242dda5d5ff8e95d10113c3a90216b35be77eff`.
- Synthetic verification snapshot: `30e39d39725a48a30fad50c842549579aec1a542`.
- Parent of the prepared SS-0025 commit:
  `891a2b9b4366868aa2b244d99009934e23b3fdda`.
- Lockfile hash: `cda66e363ca990577c574afb6c842697422bb47a`.

The verified tree applies the SS-0025 configuration boundary to the committed
workspace SDK baseline. It excludes Darwin permission metadata,
release-governance documentation, UI formatting, and local process-document
changes. Commit hashes are intentionally not invented before the user creates
the prepared commits; the immutable Git tree is the verified source identity.

## Scope

SS-0025 establishes a closed allowlist for Flutter dart-defines, strict
environment-specific schemas, public client endpoint rules, sanitized CLI
diagnostics, Make preflight targets, runtime enforcement, and regression tests.

Network IDL synchronization, signed Apple archives, notarization, physical
device media tests, validator/devnet flows, and browser E2E are outside this
ticket. They remain owned by their release tickets.

## Environment

- Dart SDK: `3.12.2` stable, macOS arm64.
- Flutter: `3.44.6` stable.
- Host platform proven by tool output: macOS arm64.

## Commands And Results

The source tree was constructed through a temporary alternate Git index and a
detached worktree. The real index and unrelated working-tree files were not
changed by verification.

The following checks passed:

- locked root and generator dependency resolution;
- `make check-app-config`;
- application analyzer and full Flutter test suite;
- analyzers and tests for `signaling`, `signaling_solana`, and `solana_wallet`;
- DCM 1.38 with zero findings;
- generated Solana SDK drift check;
- staged-diff whitespace validation.

The ignored local `config/prod.env` also passed `make validate-prod-config` in
the developer workspace. Its contents are not versioned evidence.

## Acceptance Matrix

| Scenario | Evidence | Result |
|---|---|---|
| Tracked local/dev/prod example files satisfy the closed schema | CLI and unit tests | Passed |
| Unknown, duplicate, malformed, missing, and forbidden keys are rejected | validator tests | Passed |
| RPC credentials, query, fragment, and non-root paths are rejected | endpoint policy tests | Passed |
| Public faucet paths remain supported without embedded credentials | endpoint policy tests | Passed |
| Rejected values and malformed key text do not enter diagnostics | hostile-input tests | Passed |
| Direct runtime parsing enforces the same endpoint policy | config tests | Passed |
| Existing broker and peer-invite contracts remain valid | config and architecture tests | Passed |
