# Testing Strategy

Last reviewed: 2026-07-20

## Test Levels

| Level | Purpose | Default gate |
|---|---|---|
| Unit | Pure domain, parsing, codecs, options, and failure mapping | Required |
| Package integration | Multiple real package components with controlled external boundaries | Required when available |
| Protocol E2E | Real local validator, devnet program, or key broker | Explicit opt-in target; mandatory release evidence |
| Application E2E | Real Flutter clients, platform permissions, routing, and media | Separate device/browser suite |

Mocks and fakes are appropriate at controlled unit and package boundaries.
Replacing Solana RPC, the deployed program, or the key broker means a test is
not protocol E2E and must not be labelled as such.

## Current Contract

- IDL CLI parsing and file synchronization are unit-tested.
- Network IDL synchronization through
  `packages/signaling_solana/tool/fetch_idl.dart --check` is an explicit
  contract check and is not part of the offline unit suite.
- Package tests must be named explicitly by the quality gate until workspace
  test orchestration is implemented.
- `tool/quality/verify_staged.sh` builds a detached synthetic commit from the
  Git index and runs offline/package/application checks against that exact
  tree. It does not include network IDL or protocol E2E evidence.
- Secrets, keypair bytes, SDP, ICE candidates, authorization headers, and URL
  credentials must not appear in test output or stored evidence.

## Deferred Capability

Roadmap item `BL-001` is a blocking release milestone for missing signaling
integration and E2E automation. Its work must be split into owned SS tickets
before implementation. Those tickets must provide isolated local-validator
lifecycle, a pinned program/IDL fixture, a dedicated devnet QA wallet, separate
chain and broker contract suites, and a separately scoped application E2E
phase. Release evidence records the tested app commit, fixture identity,
environment, exact command, result, and any skipped scenario; a required
scenario with no evidence keeps the gate open.

Release gates are evaluated per platform. Custody, provider-error safety,
bootstrap recovery, and core signaling evidence are common gates. Browser
payload limits, cross-client crypto vectors, and Chrome stress evidence are
additional Web release gates and do not block a non-Web platform by themselves.

SS-0017 Darwin evidence requires a physical iOS device and the distributable
macOS artifact. For each applicable platform it covers camera and microphone
allow/deny behavior, local media acquisition, offer/answer exchange, a connected
peer with two-way audio/video, disconnect cleanup, and reconnection. A simulator,
unsigned compatibility build, or successful unit suite cannot replace this
evidence.

Signed Apple distribution is separately blocked by SS-0026. SwiftPM/CocoaPods
compatibility on the pinned toolchain is not signing or device evidence.

The roadmap records gate status only. Reproducible commands, fixture identity,
source snapshot, results, and skipped scenarios live in the owning versioned
`docs/evidence/<TICKET>/` directory.
