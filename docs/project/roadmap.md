# Project Roadmap

Last reviewed: 2026-07-23

## Completed tickets

- SS-0001 — introduced the AIDD v3 workflow (merged to `main` at `9cdef2a`).
- SS-0002 — added the project README (merged to `main` at `78021e7`).
- SS-0003 — delivered Solana signaling and the architecture foundation
  (`main@e692e35`).
- SS-0013 — closed the provider-error boundary and typed safe diagnostics.
  Evidence: [SS-0013 evidence](../evidence/SS-0013/evidence.md).
- SS-0025 — enforced the public Flutter dart-define boundary and sanitized
  configuration preflight. Evidence:
  [SS-0025 evidence](../evidence/SS-0025/evidence.md).
- SS-0007 — shipped signaling parity, IDL/tooling cleanup, and the hosted
  `rolter` migration (merged by PR #3 at `967db0d`).
- SS-0008 — shipped TURN entitlement before room creation with the SS-0007
  release (merged by PR #3 at `967db0d`).

## In-flight tickets


## Common blocking release gates

- BL-001 — automate signaling integration and E2E coverage. Production
  deployment is prohibited until reproducible local-validator or devnet
  evidence covers create user/room/slot, claim, chunked offer/answer,
  confirmation, heartbeat, close/reclaim, PDA ownership, and instruction
  account parity. The gate also includes HTTP key-broker contract tests, a
  pinned Solana program fixture, and package-test quality gates. Wallet
  confirmation coverage must exercise one-signature/one-send behavior, a lost
  `sendTransaction` response, processed-to-confirmed progression, structured
  custom program failures, and blockhash expiry confirmed by a transaction
  history lookup before any retry is allowed.
- SS-0004 — define the production wallet custody and recovery model. The gate
  starts with a custody ADR covering backup/import recovery, key rotation, and
  Web multi-tab/process storage consistency. Implementation work is created
  only after that decision. Do not add an in-process mutex without a
  cross-context CAS or coordination contract.
- BL-002 — deliver a fatal bootstrap recovery experience. Cover safe pre-DI
  error rendering, typed configuration/storage/infrastructure categories, and
  retry only where initialization is repeatable. Define the bootstrap lifecycle
  and retry state model before implementing UI.
- SS-0024 — make wallet balance presentation distinguish `loading`, confirmed
  `value`, and `unavailable`. An RPC failure must never render as a confirmed
  zero balance; a retained value must be visibly stale. Migrate both Home and
  Hub consumers to one presentation contract and cover initial, refresh,
  failure, recovery, and disposal behavior with widget tests.

`BL-001` is a milestone, not one executable ticket. Its implementation must be
delivered through:

- SS-0014 — validator protocol flow and pinned program/IDL fixture;
- SS-0015 — HTTP key-broker contracts;
- SS-0016 — transaction-confirmation reliability;
- SS-0017 — per-platform application smoke and E2E evidence.

## Web-specific blocking release gates

- BL-003 — specify and verify signaling payload protocol security before Web
  production. Delivery is split into SS-0018 protocol decision, SS-0019 bounded
  Web implementation, SS-0020 cross-client vectors, and SS-0021 Chrome stress
  tests.
  Do not change `v:3/z:1` or add a custom RFC 1950 parser without the protocol
  decision.

## Apple-specific blocking release gates

- SS-0026 — establish the production Apple identity and signed distribution
  workflow. iOS and macOS releases remain prohibited while bundle identifiers,
  Apple Team ownership, iOS distribution, Developer ID Application signing,
  Hardened Runtime, minimum camera/audio-input entitlements, secure timestamp,
  notarization, stapling, Gatekeeper verification, and clean-machine artifact
  installation are unproven. Signing credentials stay outside Git and
  dart-defines. The first macOS channel is direct Developer ID distribution.

A platform release is prohibited while a common gate, one of that platform's
specific gates, or its required smoke evidence is open. A gate closes only
through owned SS implementation tickets with reviewed acceptance matrices and
reproducible versioned evidence; critical scenarios may not be skipped. The
roadmap stores status and links, while commands, fixture identity, source
snapshot, and results remain in the owning ticket evidence directory.

| Platform | Common gates | Platform-specific gates | Required app evidence |
|---|---|---|---|
| Android | BL-001, SS-0004, BL-002, SS-0024 | None currently registered | SS-0017 Android smoke |
| iOS | BL-001, SS-0004, BL-002, SS-0024 | SS-0026 | SS-0017 iOS device smoke |
| macOS | BL-001, SS-0004, BL-002, SS-0024 | SS-0026 | SS-0017 signed macOS artifact smoke |
| Linux | BL-001, SS-0004, BL-002, SS-0024 | None currently registered | SS-0017 Linux smoke |
| Windows | BL-001, SS-0004, BL-002, SS-0024 | None currently registered | SS-0017 Windows smoke |
| Web | BL-001, SS-0004, BL-002, SS-0024 | SS-0018, SS-0019, SS-0020, SS-0021 | SS-0017 Web/Chrome smoke |

## Planned

- SS-0009 — DDD, workflow, package-boundary, and security hardening. Critical;
  starts after SS-0007 and SS-0008 ship.
- SS-0011 — room directory listing transferred from SS-0007 Phase 5.
- SS-0012 — signaling reliability work transferred from SS-0007 Phase 6.
- SS-0022 — define the bootstrap lifecycle and retry state model required by
  BL-002 before implementing recovery UI.
- SS-0023 — define allowlisted normalized DTOs and retention policy before
  integrating Sentry, Crashlytics, or another remote reporter.
- SS-0027 — gate Flutter or `flutter_webrtc` upgrades on Darwin dependency
  compatibility. The current Flutter 3.44.6 project has SwiftPM integration,
  while `flutter_webrtc` 1.5.2 still uses Flutter's CocoaPods fallback. Before
  an upgrade, run clean iOS/macOS release builds and preserve complete
  CocoaPods/SwiftPM diagnostics. If upstream SwiftPM support remains absent,
  use a separate ADR to choose a maintained fork, replacement, or temporarily
  pinned CocoaPods toolchain. Do not create an app-level `Package.swift` as an
  unowned plugin workaround.

## Deferred / open items

- SS-0005 — replace the workspace-internal `SolanaFundingService.ensureFunded`
  boolean consumed by `signaling_solana` with sealed outcomes:
  `alreadyFunded`, `funded`, `transientFailure`, and `permanentFailure`. Remove
  the boolean only after the adapter handles every outcome without parsing
  messages or leaking retry classification into `signaling`.
- BL-005 — remove the application-to-data dependency from
  `OnChainPeerSignaling` to `PassphrasePayloadCrypto` when a second crypto
  implementation, isolated application test seam, or protocol redesign
  provides a concrete port requirement. This structural debt is not itself a
  release blocker and must not be mixed into BL-003 wire-protocol changes.
- BL-006 — make the AIDD quality wrapper propagate DCM failures and reconcile
  the current member-ordering, unused-ignore, and file-name warnings. Until
  then DCM output is advisory and must be reviewed explicitly rather than
  reported as a passing hard gate.

## Last 3 changes

- 2026-07-23 — shipped SS-0007 and SS-0008 together through PR #3
  (`967db0d`), completing signaling parity and TURN-entitlement delivery.
- 2026-07-20 — closed SS-0025 and registered Apple signing and Darwin
  dependency-manager gates SS-0026/SS-0027.
- 2026-07-19 — closed SS-0013 against its verified source tree and made wallet
  address logging forbidden in every environment.
