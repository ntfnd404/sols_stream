import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realtime_media/realtime_media.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/stream_viewport.dart';

void main() {
  late RTCVideoRenderer localRenderer;
  late RTCVideoRenderer remoteRenderer;

  setUp(() {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
  });

  tearDown(() async {
    await localRenderer.dispose();
    await remoteRenderer.dispose();
  });

  testWidgets('publisher shows local video as primary before peer connects', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: false,
        ),
      ),
    );

    final videos = tester.widgetList<RTCVideoView>(
      find.byType(RTCVideoView),
    );
    expect(videos, hasLength(1));
    expect(videos.single.videoRenderer, same(localRenderer));
    expect(videos.single.mirror, isTrue);
    expect(_bottomRightPip(), findsNothing);
  });

  testWidgets('publisher moves local video to bottom-right PiP after peer connects', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
        ),
      ),
    );

    final videos = tester
        .widgetList<RTCVideoView>(
          find.byType(RTCVideoView),
        )
        .toList();
    expect(videos, hasLength(2));
    expect(videos.first.videoRenderer, same(remoteRenderer));
    expect(videos.first.mirror, isFalse);
    expect(videos.last.videoRenderer, same(localRenderer));
    expect(videos.last.mirror, isTrue);
    expect(_bottomRightPip(), findsOneWidget);
    expect(find.text('REMOTE PARTICIPANT'), findsOneWidget);
    expect(find.text('LOCAL PREVIEW'), findsOneWidget);
  });

  testWidgets('tap-to-swap moves the stream labels with their renderers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('stream-viewport-pip')));
    await tester.pump();

    final videos = tester.widgetList<RTCVideoView>(find.byType(RTCVideoView)).toList();
    expect(videos.first.videoRenderer, same(localRenderer));
    expect(videos.last.videoRenderer, same(remoteRenderer));
    expect(find.text('LOCAL PREVIEW'), findsOneWidget);
    expect(find.text('REMOTE PARTICIPANT'), findsOneWidget);
  });

  testWidgets('local publishing state does not hide either renderer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
        ),
      ),
    );

    expect(_bottomRightPip(), findsOneWidget);
    expect(find.text('Peer camera is off'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('stream-viewport-pip')));
    await tester.pump();

    expect(_bottomRightPip(), findsOneWidget);
    expect(find.text('Peer camera is off'), findsNothing);
  });

  testWidgets('remote camera off follows the remote renderer after swap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
          remoteCameraEnabled: false,
        ),
      ),
    );

    expect(find.text('Peer camera is off'), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stream-viewport-pip')));
    await tester.pump();

    expect(find.text('Peer camera is off'), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
  });

  testWidgets('remote microphone badge follows the remote renderer after swap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
          remoteMicrophoneEnabled: false,
        ),
      ),
    );

    expect(find.text('Peer microphone is off'), findsOneWidget);
    expect(find.byIcon(Icons.mic_off), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stream-viewport-pip')));
    await tester.pump();

    expect(find.text('Peer microphone is off'), findsNothing);
    expect(find.byIcon(Icons.mic_off), findsOneWidget);
  });

  testWidgets('camera placeholder and microphone badge can be shown together', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
          remoteCameraEnabled: false,
          remoteMicrophoneEnabled: false,
        ),
      ),
    );

    expect(find.text('Peer camera is off'), findsOneWidget);
    expect(find.text('Peer microphone is off'), findsOneWidget);
  });

  testWidgets('hiding local PiP restores remote as the only renderer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('stream-viewport-pip')));
    await tester.pump();
    expect(
      tester.widgetList<RTCVideoView>(find.byType(RTCVideoView)).first.videoRenderer,
      same(localRenderer),
    );

    await tester.pumpWidget(
      _TestApp(
        child: _viewport(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          remoteVideoAvailable: true,
          showLocalPreviewPip: false,
        ),
      ),
    );

    final videos = tester.widgetList<RTCVideoView>(find.byType(RTCVideoView));
    expect(videos, hasLength(1));
    expect(videos.single.videoRenderer, same(remoteRenderer));
  });
}

Finder _bottomRightPip() => find.byWidgetPredicate(
  (widget) => widget is Align && widget.alignment == Alignment.bottomRight,
);

StreamViewport _viewport({
  required RTCVideoRenderer localRenderer,
  required RTCVideoRenderer remoteRenderer,
  required bool remoteVideoAvailable,
  bool remoteCameraEnabled = true,
  bool remoteMicrophoneEnabled = true,
  bool showLocalPreviewPip = true,
}) => StreamViewport(
  transportMode: TransportMode.webrtc,
  webRtcRole: WebRtcRole.publisher,
  videoController: null,
  localStreamActive: true,
  remoteVideoAvailable: remoteVideoAvailable,
  remoteCameraEnabled: remoteCameraEnabled,
  remoteMicrophoneEnabled: remoteMicrophoneEnabled,
  showLocalPreviewPip: showLocalPreviewPip,
  localRenderer: localRenderer,
  remoteRenderer: remoteRenderer,
);

// Test-only harness intentionally stays beside the viewport scenarios.
// ignore: prefer-match-file-name
class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 640, height: 360, child: child),
    ),
  );
}
