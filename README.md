# sols.stream

Open streaming platform — watch live streams, broadcast, make P2P and group calls.

## Vision

sols.stream is a cross-platform streaming platform built on Flutter and WebRTC. The goal is a single app where anyone can:

- **Watch** live streams and VOD
- **Broadcast** a live stream from any device
- **Call** anyone P2P with video and audio
- **Join** group calls and rooms

## What works now

**WebRTC (P2P)**
- Publisher / Viewer roles
- Solana on-chain offer/answer signaling
- Encrypted SDP exchange with local and remote key-broker adapters
- Canonical invite links for the Dart Web, mobile, and desktop clients
- Video 1280×720 @ 30fps + audio
- STUN / TURN server configuration
- Swappable local-preview PiP and remote participant surfaces
- Camera publication and microphone capture controls

**HLS / LL-HLS playback**
- URL-based stream playback
- Basic Auth (username / password) and Bearer token support
- Platforms: Android, iOS, macOS, Web

## Roadmap

- [ ] Multi-peer P2P rooms
- [ ] Define and implement Stream session mode
- [ ] Group calls / SFU topology
- [ ] Stream catalog — browse and join live streams
- [ ] Screen sharing
- [ ] Recording and VOD
- [ ] Adaptive bitrate and codec negotiation

## Getting started

### Requirements

- Flutter SDK providing Dart `^3.12.2`; exact verified toolchain versions are
  recorded with release evidence
- Xcode for iOS and macOS
- Android Studio and an Android SDK for Android
- Visual Studio with Desktop development with C++ for Windows
- Linux desktop build dependencies for Linux
- Docker Desktop on Apple Silicon for the supplied local Solana validator image

Run `flutter doctor` before launching a platform for the first time.

### Run against devnet

```bash
flutter pub get
make run-dev-mobile    # interactive Android/iOS selection
make run-dev-android   # mobile-selection alias
make run-dev-ios       # mobile-selection alias
make run-dev-macos
make run-dev-linux
make run-dev-windows
make run-dev-web
make run-dev-chrome
```

An optional `DEVICE=<id-or-name>` selects a mobile target for automation.
The dev environment uses Solana devnet and the remote key broker, but serves
the Dart Web client locally at `http://localhost:8080`. Public Dart Web hosting
is not configured yet.

### Run with production configuration

Create the ignored `config/prod.env` from `config/prod.example.env`, replace
every example endpoint with the real production value, then use:

```bash
make run-prod-mobile
make run-prod-android
make run-prod-ios
make run-prod-macos
make run-prod-linux
make run-prod-windows
make run-prod-web
```

Production commands run Flutter in release mode. Do not treat the example
endpoints as deployable configuration.

### Run against local Solana node

For local development against the Docker validator:

```bash
make node-build-arm64   # first time only (~45 min)
make node-up
make run-local-web      # release Flutter web-server at http://localhost:8080
make run-local-macos    # publisher; run in a second terminal
```

Local publisher links target
`http://localhost:8080/home?intent=p2p&role=viewer&host=...`. The Flutter web
client opens in Viewer mode; the user taps **Connect** to join through the same
local Solana node. Treat each environment file as one configuration unit; do
not mix its RPC, web-client, or key-broker values with another environment.
Local uses `APP_ENVIRONMENT=local` with `KEY_BROKER_MODE=local`. Dev uses
`APP_ENVIRONMENT=dev`, `KEY_BROKER_MODE=http`, and the configured
proof-verifying HTTPS broker.

For a complete call on one Mac:

1. Run `make node-up`.
2. Run `make run-local-web` for the viewer.
3. Run `make run-local-macos` for the publisher in another terminal.
4. Create the call in the macOS app and open its localhost invite in Chrome.

The host and viewer account UI must show different wallet addresses. Wallet
addresses are never written to logs. Two normal tabs on the same origin share
web storage and therefore share one wallet; use macOS + Chrome, or separate
normal/incognito browser profiles. The app rejects a host invite opened by the
same wallet before starting media or submitting a viewer transaction.

Safe diagnostics are emitted under `Environment`, `Wallet`, `Call`, and
`Signaling`. They report lifecycle stages and exception types without logging
SDP, ICE candidates, capability secrets, protected keys, or TURN credentials.
Key-broker failures include only the HTTP status, never the response body.
The local broker adapter is intentionally development-only: its scoped,
expiring capability envelope is readable by anyone with access to local
validator account data.

`make run-local-web` delegates release compilation, HTTP serving, and SPA
fallback to Flutter's standard `web-server` device. Open the printed URL in a
browser. Use `make run-local-web-debug` for a debug web-server or
`make run-local-chrome` for Flutter-managed Chrome with hot reload.

Additional local commands cover the remaining generated Flutter targets:

```bash
make run-local-mobile
make run-local-android
make run-local-ios
make run-local-linux
make run-local-windows
```

The local Web client is intentionally same-host only. `localhost` is a secure
browser context, while an HTTP LAN address is not suitable for camera and
microphone access. Android emulators need a `10.0.2.2` RPC override. Physical
devices are not supported by the supplied loopback-only validator Compose;
exposing local RPC to a LAN requires a separately reviewed bind/firewall
configuration. Serving the Web client over LAN remains out of scope until local
HTTPS is introduced. `LOCAL_WEB_BIND_HOST` and `LOCAL_WEB_BIND_PORT` are loaded
from `config/tooling/local_web.env` and are never passed to Flutter dart-defines.
See the [`Docker setup guide`](docker/README.md) for details.

### Refresh the Solana IDL

The versioned on-chain contract belongs to `packages/signaling_solana`:

```bash
cp config/tooling/idl.example.env config/tooling/idl.env  # first time only
make check-idl   # compare devnet with the checked-in artifact, no writes
make fetch-idl   # refresh the checked-in artifact
make check-solana-sdk  # verify generated Dart SDK drift without RPC access
```

Both targets use `IDL_RPC_URL` from `config/tooling/idl.env` by default. This
tooling file is not passed to Flutter. Override `IDL_ENV_FILE`, `IDL_RPC_URL`,
or `IDL_OUT` explicitly when checking another deployment.

### How to make a P2P call

**Publisher (broadcaster):**
1. Open **P2P Call** or select **P2P** and **Publisher**
2. Tap **Go Live**
3. Copy the generated invite link and send it to the viewer
4. Keep the publisher session open while the viewer connects

**Viewer:**
1. Open the invite link, or select **P2P** and **Viewer**
2. Paste the publisher invite when it was not supplied by the URL
3. Tap **Connect**

The canonical web routes are `/home?intent=p2p&role=publisher` and
`/home?intent=p2p&role=viewer`. Stream sessions are reserved but unavailable
until their product and transport contract is defined. These are browser routes,
not Universal Links or App Links; opening the native app from an HTTPS invite is
not implemented.

### How to watch an HLS stream

1. Select **HLS** mode
2. Paste the stream URL (`.m3u8`)
3. Enter Basic Auth credentials or Bearer token if required
4. Tap **Play**

## Platform support

| Platform | WebRTC | HLS |
|----------|:------:|:---:|
| macOS    | ✅     | ✅  |
| iOS      | ✅     | ✅  |
| Android  | ✅     | ✅  |
| Web      | ✅     | ✅  |
| Linux    | ✅     | ❌  |
| Windows  | ✅     | ❌  |

## Tech stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter / Material 3 |
| Presentation | BLoC + typed routes + ephemeral UI actions |
| WebRTC runtime | `packages/realtime_media` + `flutter_webrtc` |
| HLS playback | `packages/streaming` + `video_player` |
| Signaling protocol | `packages/signaling` |
| Solana signaling adapter | `packages/signaling_solana` |
| Solana wallet | `packages/solana_wallet` |
| Secure persistence | `packages/secure_storage` |

## Contributing

Work follows the [AIDD v3 workflow](docs/project/workflow.md). Start with `/aidd-new-ticket SS-XXXX` before any feature branch.
