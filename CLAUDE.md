# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**sols.stream MWP** — a Flutter minimum working product for WebRTC streaming and HLS/LL-HLS playback. The entire app lives in a single file: `lib/main.dart`.

## Commands

```bash
# Run on a connected device or simulator
flutter run

# Run on a specific platform
flutter run -d macos
flutter run -d chrome

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Build
flutter build macos
flutter build apk
flutter build web
```

## Architecture

The app is a single `StatefulWidget` (`_StreamMwpHomeState`) with two transport modes controlled by `TransportMode` enum:

**WebRTC mode** (`flutter_webrtc`) — manual copy-paste signaling (no signaling server). Flow:
1. Start local media (`getUserMedia`)
2. Create offer or answer → ICE candidates are gathered inline (5 s timeout in `_waitForIceGathering`)
3. Local SDP is serialized as JSON: `{type, sdp, session, token, role}` — copy to clipboard
4. Paste remote SDP JSON and apply
- Supports publisher and viewer roles (`WebRtcRole` enum)
- PiP overlay shows local stream when remote video is active

**HLS mode** (`video_player`) — URL + optional Basic Auth or Bearer token. HLS is only supported on Android, iOS, macOS, and Web (`_hlsSupported` gate). Linux and Windows are not supported.

## Code conventions

### State management
- Only `Bloc<Event, State>` — never `Cubit`. Every feature owns its own Bloc.
- Each Bloc lives in `lib/feature/<name>/bloc/` (`*_bloc.dart`, `*_event.dart`, `*_state.dart`, `*_action.dart`).
- Scoped DI via `*Scope` classes: `FooScope.create(BuildContext)` reads from `AppScope` and constructs the Bloc.
- `EphemeralBlocMixin` for one-shot side effects (snackbars, navigation) — not stored in state.
- Events are sealed classes. State is immutable with `copyWith()`.
- Bloc never holds Flutter platform objects (`RTCVideoRenderer`, `TextEditingController`) — those stay in `StatefulWidget` and are wired via `BlocListener`.

### Widget structure
- No `_buildXxx()` helper methods that return `Widget` — extract into `StatelessWidget` / `StatefulWidget`.
- Shared widgets → `lib/common/widgets/`, extensions → `lib/common/extensions/`.

### Signaling / crypto
- `PeerSignaling` is the only application port used by Web, mobile, and desktop.
- `OnChainPeerSignaling` exchanges broker-protected SDP through Solana slots.
- Platform-specific WebRTC remains isolated in `realtime_media`.

## Platform notes

- `ios/Podfile` and `macos/Podfile` are committed (non-standard — CocoaPods managed)
- Camera/mic permissions must be declared in `AndroidManifest.xml` and `Info.plist` (already present)
- `flutter_webrtc` requires platform-specific camera/mic entitlements on macOS (`DebugProfile.entitlements`, `Release.entitlements`)
