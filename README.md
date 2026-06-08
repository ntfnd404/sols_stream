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
- Manual SDP exchange (copy-paste JSON) — no signaling server required
- Video 1280×720 @ 30fps + audio
- STUN / TURN server configuration
- PiP overlay for local stream while viewing remote
- Mic and camera toggle during session

**HLS / LL-HLS playback**
- URL-based stream playback
- Basic Auth (username / password) and Bearer token support
- Platforms: Android, iOS, macOS, Web

## Roadmap

- [ ] Signaling server (WebSocket) — remove manual SDP exchange
- [ ] Group calls (SFU-based)
- [ ] Stream catalog — browse and join live streams
- [ ] Screen sharing
- [ ] Recording and VOD
- [ ] Adaptive bitrate and codec negotiation

## Getting started

### Requirements

- Flutter ≥ 3.12.0 ([install](https://flutter.dev/docs/get-started/install))
- For macOS: Xcode + CocoaPods (`brew install cocoapods`)
- For Android: Android Studio + NDK

### Run

```bash
flutter pub get
flutter run -d macos     # desktop
flutter run -d chrome    # web
flutter run              # connected mobile device
```

### How to make a P2P call

**Publisher (broadcaster):**
1. Select **WebRTC** mode and **Publisher** role
2. Tap **Start Local Media** — camera and mic start
3. Tap **Create Offer** — local SDP JSON is generated and copied to clipboard
4. Send the SDP JSON to the viewer (any channel: chat, email, etc.)
5. Paste the viewer's Answer SDP into the remote SDP field
6. Tap **Apply Remote SDP** — connection established

**Viewer:**
1. Select **WebRTC** mode and **Viewer** role
2. Paste the publisher's Offer SDP into the remote SDP field
3. Tap **Create Answer** — answer SDP is generated and copied to clipboard
4. Send the answer SDP back to the publisher

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
| WebRTC | [flutter_webrtc](https://pub.dev/packages/flutter_webrtc) ^1.4.1 |
| HLS playback | [video_player](https://pub.dev/packages/video_player) ^2.11.1 |
| Signaling | Manual (copy-paste) — server planned |

## Contributing

Work follows the [AIDD v3 workflow](docs/project/workflow.md). Start with `/aidd-new-ticket SS-XXXX` before any feature branch.
