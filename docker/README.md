# Local Solana node

Runs `solana-test-validator` with the signaling program and `ProgramConfig`
cloned from devnet. Once the validator is ready, application development and
P2P calls use local RPC and local test SOL rather than spending devnet SOL.

Creating a clean ledger requires devnet access because Compose clones the
program accounts during ledger initialization. Normal stop/start cycles reuse
the named ledger volume and do not intentionally refresh those accounts.

## Requirements

- [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/)
- Apple Silicon for the supplied `solana-local:arm64` image
- Network access to Solana devnet while the validator clones the program

## First-time setup

Build the native ARM64 image (one-time per selected Agave revision, ~45 min).
The default is tag `v2.1.21` verified against commit
`8a085eebcb901b6846d1f82f4636667742146545`:

```bash
make node-build-arm64
```

An upgrade must provide both the reviewed tag and its expected commit:

```bash
make node-build-arm64 AGAVE_VERSION=<tag> AGAVE_COMMIT=<full-commit>
```

Compiles `solana-test-validator` from Agave source inside a Docker builder stage
(Agave does not publish pre-built Linux ARM64 binaries). The resulting image is
named `solana-local:arm64`. You only need to do this once — the image stays on
your machine until you delete it.

The Agave source revision is pinned, but the Rust/Debian base images and Debian
package repository snapshots are not digest-locked. This is repeatable local
development tooling, not a bit-reproducible release artifact.

## Start the node

```bash
make node-up
```

When initializing a clean ledger the validator clones two accounts from devnet:

| What | Address |
|------|---------|
| Signaling program (binary) | `8rYyL3AY3cb4XrFWfUokXKwQb8uU48XvuLAHNxTgdmXw` |
| ProgramConfig PDA | `8G39qp7r5dQ3bUsvb7F7xTAsAKeD9yBNB5oLBtANUeUA` |

The node is ready when `make node-status` shows `healthy` or when:

```bash
curl http://localhost:8899/health   # → ok
```

The Docker healthcheck additionally requires a non-zero confirmed slot. The
plain `/health` endpoint can return `ok` while the validator is still cloning
the program and cannot yet confirm transactions. `make node-up` and
`make node-reset` wait for the stronger readiness condition.

RPC and WebSocket ports are published on host loopback only. They are not
intended to expose an unauthenticated development validator to the LAN.

## Run the app against the local node

```bash
make run-local-mobile      # Flutter selects an Android/iOS device
make run-local-android     # alias for run-local-mobile
make run-local-ios         # alias for run-local-mobile
make run-local-macos       # macOS desktop
make run-local-linux       # Linux desktop
make run-local-windows     # Windows desktop
make run-local-web         # release Flutter web-server at localhost:8080
make run-local-web-debug   # debug Flutter web-server at localhost:8080
make run-local-chrome      # Flutter-managed Chrome with hot reload
```

When several mobile devices are connected, Flutter presents an interactive
selection. Automation can select one without changing the Makefile:

```bash
make run-local-android DEVICE=emulator-5554
make run-local-ios DEVICE="iPhone"
```

Desktop and Web clients running on the same host as the validator reach it
through `http://localhost:8899`. An iOS simulator on macOS also shares the Mac
host network.

Android emulators do not map `localhost` to the development computer. They
normally use `10.0.2.2` for the host, so `SOLANA_RPC_URL` and
`SOLANA_AIRDROP_RPC_URL` need platform-specific overrides. The supplied Compose
publishes RPC on host loopback only, so physical Android and iOS devices are not
supported by this setup. Supporting them requires a separately reviewed LAN
bind and firewall policy. The current `config/local.env` is the same-host
default; do not expect it to work unchanged on those targets.

`config/local.env` sets
`PEER_INVITE_BASE_URL=http://localhost:8080/home?intent=p2p&role=viewer`.
Publisher
invite links therefore stay inside the local environment. Opening one in the
local Flutter web client selects Viewer mode; the user then taps **Connect**.
`APP_ENVIRONMENT=local` with `KEY_BROKER_MODE=local` selects the stateless
local capability adapter. A remote broker validates claims against its own
cluster and cannot release keys for local-validator PDAs.

Flutter's standard web-server binds to `localhost:8080` by default. Its bind
address and port come from `config/tooling/local_web.env`:

```bash
make run-local-web
```

The browser client is same-host only. Do not expose this HTTP server through
`0.0.0.0` for a physical Web client: non-localhost HTTP origins do not provide
the secure context required for camera and microphone. Native physical clients
also cannot reach the loopback-only validator in the supplied Compose setup.

## Run the app against devnet

The same platform matrix is available without the local validator:

```bash
make run-dev-mobile
make run-dev-android
make run-dev-ios
make run-dev-macos
make run-dev-linux
make run-dev-windows
make run-dev-web
```

These commands use `config/dev.env`, the public devnet RPC, the remote key
broker, and a locally served viewer at `http://localhost:8080`. Public Dart Web
deployment is intentionally deferred.

## Test a call on one Mac

Use two clients with separate wallet storage:

```bash
# Terminal 1
make node-up

# Terminal 2: viewer
make run-local-web

# Terminal 3: publisher
make run-local-macos
```

Create the P2P call in the macOS app and open the generated localhost link in
Chrome. The Web route selects Viewer mode; tap **Connect** to join. It is not a
native Universal Link or App Link.

Do not use two regular Chrome tabs: they share the same origin storage and
wallet identity. A normal and an Incognito window are acceptable alternatives,
provided both can access camera/microphone. A host invite cannot be joined by
the same wallet: the Dart client rejects that role conflict before media startup
or any viewer-side chain mutation.

Diagnostics:

- macOS: the `flutter run` terminal or Console.app;
- Web: Chrome DevTools → Console;
- verify that the two clients show different wallet addresses in their UI;
- follow `Call`, `Signaling`, `publisher.*`, `host.*`, `chain.*`, and
  `viewer.*` events to locate the failed stage.
- `viewer.self_connection.rejected` means both clients resolved to the same
  wallet; use a separate app/browser profile.
- `KeyBrokerException ... status=N` identifies the broker response without
  printing its body or request secrets.

If no `Environment` or `chain.*` events appear, verify Docker Desktop is
running first. `make node-status` must report `healthy`; otherwise run
`make node-up` and wait for it to complete before starting either Flutter
client.

SOL is requested through the local validator RPC when the wallet balance is
low. Port `8900` is the validator WebSocket endpoint, not the project's HTTP
faucet service.

Transactions are submitted and then explicitly polled to `confirmed` before a
dependent instruction is sent. This is required for flows such as
`create_user -> purchase_turn -> create_room -> open_slot`; the Solana Dart
SDK's `signAndSendTransaction` method submits but does not itself wait for
confirmation.

## Other commands

```bash
make node-logs    # tail validator output
make node-status  # show container health
make node-down    # stop the node and retain its named ledger volume
make node-reset   # delete the ledger volume, clone again, and restart fresh
```

## Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Compose config — ports, command, healthcheck |
| `Dockerfile.solana-arm64` | Multi-stage build for native ARM64 image |

## Notes

- `node-down` retains the named ledger volume. `node-reset` is the explicit
  destructive operation that deletes it and requires devnet access to clone
  the program and config again.
- The container has no automatic restart policy. A failed validator remains
  stopped so it cannot silently recreate or repeatedly mutate local state.
- The supplied image is ARM64-only. Linux/Windows Flutter targets are part of
  the application platform matrix, but running this specific local validator
  image on an x64 development host requires a separate x64 image.
- Never use `KEY_BROKER_MODE=local` outside an isolated local validator. Its
  capability envelope enables cross-process development but is not a
  production security boundary.
