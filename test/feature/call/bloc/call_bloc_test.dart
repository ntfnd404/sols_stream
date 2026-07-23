import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:realtime_media/realtime_media.dart';
import 'package:signaling/signaling.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';
import 'package:sols_stream/core/event_bus/events/call_session_invalidated_app_event.dart';
// call_event.dart and call_state.dart are part files of call_bloc.dart.
import 'package:sols_stream/feature/call/bloc/call_bloc.dart';
import 'package:sols_stream/feature/call/view/call_controls_panel.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/publisher_controls.dart';

import 'fakes/fake_media_stream.dart';
import 'fakes/fake_realtime_media_session.dart';
import 'mocks/mock_media_stream_track.dart';
import 'stubs/stub_peer_signaling.dart';

void _ignoreRoleChange(WebRtcRole _) {}
void _ignoreSessionModeChange(SessionMode _) {}

PeerHostSession _hostSession({
  required Future<void> Function() teardown,
  void Function()? cancelWaiting,
}) => PeerHostSession(
  connectionUrl: 'https://example.test/home?intent=p2p&role=viewer',
  slotPda: 'slot',
  awaitAnswerSdp: () => Completer<String>().future,
  confirm: () async {},
  cancelWaiting: cancelWaiting ?? () {},
  teardown: teardown,
);

// ── Factory ───────────────────────────────────────────────────────────────────

CallBloc _makeBloc({
  AppEventBus? eventBus,
  RealtimeMediaSessionController? mediaSession,
  PeerSignaling peerSignaling = const StubPeerSignaling(),
}) => CallBloc(
  peerSignaling: peerSignaling,
  mediaSession: mediaSession ?? FakeRealtimeMediaSession(),
  eventBus: eventBus ?? AppEventBus(),
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('CallBloc', () {
    group('initial state', () {
      test('starts idle with all flags false/default', () {
        final bloc = _makeBloc();
        expect(bloc.state, const CallState());
        expect(bloc.state.goingLive, isFalse);
        expect(bloc.state.connecting, isFalse);
        expect(bloc.state.viewerConnected, isFalse);
        expect(bloc.state.localStreamActive, isFalse);
        expect(bloc.state.micEnabled, isTrue);
        expect(bloc.state.cameraEnabled, isTrue);
        expect(bloc.state.showLocalPreviewPip, isTrue);
        expect(bloc.state.rtcState, 'Idle');
        bloc.close();
      });
    });

    test('failed Go Live releases local media capture', () async {
      final mediaSession = FakeRealtimeMediaSession();
      final bloc = _makeBloc(mediaSession: mediaSession);
      addTearDown(bloc.close);

      final failedState = bloc.stream.firstWhere(
        (state) => state.status == 'Go Live failed. Check your wallet and connection.',
      );
      final failureAction = bloc.actionStream.first;
      bloc.add(
        const GoLiveRequestedEvent(
          rtcConfiguration: <String, dynamic>{},
        ),
      );

      final state = await failedState;
      expect(state.goingLive, isFalse);
      expect(state.localStreamActive, isFalse);
      expect(state.localStream, isNull);
      expect(mediaSession.disposeCalls, 1);
      expect(
        await failureAction,
        isA<ShowStatusMessageAction>().having(
          (action) => action.message,
          'message',
          'Go Live failed. Check your wallet and connection.',
        ),
      );
    });

    group('DisconnectRequestedEvent — Bug 3 fix', () {
      // DisconnectRequestedEvent must reset ALL flow flags including goingLive and
      // connecting so the UI is never left stuck in a loading state.
      blocTest<CallBloc, CallState>(
        'resets all flags when no active session',
        build: _makeBloc,
        act: (bloc) => bloc.add(const DisconnectRequestedEvent()),
        expect: () => [
          isA<CallState>().having((s) => s.status, 'status', 'Disconnecting…'),
          isA<CallState>()
              .having((s) => s.goingLive, 'goingLive', isFalse)
              .having((s) => s.connecting, 'connecting', isFalse)
              .having((s) => s.viewerConnected, 'viewerConnected', isFalse)
              .having((s) => s.localStreamActive, 'localStreamActive', isFalse)
              .having((s) => s.remoteVideoAvailable, 'remoteVideoAvailable', isFalse)
              .having((s) => s.rtcState, 'rtcState', 'Idle')
              .having((s) => s.status, 'status', 'Disconnected.'),
        ],
      );

      blocTest<CallBloc, CallState>(
        'resets goingLive: true from seeded state',
        build: _makeBloc,
        seed: () => const CallState(goingLive: true, connecting: true),
        act: (bloc) => bloc.add(const DisconnectRequestedEvent()),
        expect: () => [
          isA<CallState>(),
          isA<CallState>()
              .having((s) => s.goingLive, 'goingLive', isFalse)
              .having((s) => s.connecting, 'connecting', isFalse),
        ],
      );

      late List<String> teardownOrder;
      late Completer<void> reclaimStarted;
      late Completer<void> releaseReclaim;
      blocTest<CallBloc, CallState>(
        'stops media before waiting for host reclaim',
        setUp: () {
          teardownOrder = [];
          reclaimStarted = Completer<void>();
          releaseReclaim = Completer<void>();
        },
        build: () => _makeBloc(
          mediaSession: FakeRealtimeMediaSession(
            onDispose: () async {
              teardownOrder.add('media');
            },
          ),
        ),
        seed: () => CallState(
          localStreamActive: true,
          hostSession: _hostSession(
            teardown: () async {
              teardownOrder.add('reclaim');
              reclaimStarted.complete();
              await releaseReclaim.future;
            },
          ),
        ),
        act: (bloc) async {
          bloc.add(const DisconnectRequestedEvent());
          await reclaimStarted.future;
          expect(teardownOrder, ['media', 'reclaim']);
          releaseReclaim.complete();
        },
        expect: () => [
          isA<CallState>()
              .having(
                (state) => state.disconnecting,
                'disconnecting',
                isTrue,
              )
              .having(
                (state) => state.status,
                'status',
                'Disconnecting…',
              ),
          isA<CallState>()
              .having(
                (state) => state.disconnecting,
                'disconnecting',
                isFalse,
              )
              .having(
                (state) => state.status,
                'status',
                'Disconnected.',
              ),
        ],
      );

      late int lifecycleTeardownCalls;
      late int cancelWaitingCalls;
      blocTest<CallBloc, CallState>(
        'closing the Bloc tears down an active host session exactly once',
        setUp: () {
          lifecycleTeardownCalls = 0;
          cancelWaitingCalls = 0;
        },
        build: _makeBloc,
        seed: () => CallState(
          localStreamActive: true,
          hostSession: _hostSession(
            cancelWaiting: () => cancelWaitingCalls++,
            teardown: () async {
              lifecycleTeardownCalls++;
            },
          ),
        ),
        verify: (_) {
          expect(cancelWaitingCalls, 1);
          expect(lifecycleTeardownCalls, 1);
        },
      );

      late List<String> closeOrder;
      late FakeRealtimeMediaSession closingMediaSession;
      blocTest<CallBloc, CallState>(
        'close finishes media cleanup before reclaim and reclaims after media failure',
        setUp: () {
          closeOrder = [];
          closingMediaSession = FakeRealtimeMediaSession(
            onClose: () async => closeOrder.add('media'),
            closeError: StateError('media close failed'),
          );
        },
        build: () => _makeBloc(mediaSession: closingMediaSession),
        seed: () => CallState(
          localStreamActive: true,
          hostSession: _hostSession(
            teardown: () async => closeOrder.add('reclaim'),
          ),
        ),
        verify: (_) {
          expect(closeOrder, ['media', 'reclaim']);
          expect(closingMediaSession.closeCalls, 1);
        },
      );
    });

    group('CallSessionInvalidatedAppEvent', () {
      late AppEventBus eventBus;

      blocTest<CallBloc, CallState>(
        'does nothing when no WebRTC session is active',
        build: () {
          eventBus = AppEventBus();
          addTearDown(eventBus.dispose);

          return _makeBloc(eventBus: eventBus);
        },
        act: (_) => eventBus.emit(
          const CallSessionInvalidatedAppEvent(
            CallSessionInvalidationReason.roleChanged,
          ),
        ),
        wait: const Duration(milliseconds: 10),
        expect: () => <CallState>[],
      );

      blocTest<CallBloc, CallState>(
        'disconnects active WebRTC session without a HomeBloc reference',
        build: () {
          eventBus = AppEventBus();
          addTearDown(eventBus.dispose);

          return _makeBloc(eventBus: eventBus);
        },
        seed: () => const CallState(localStreamActive: true),
        act: (_) => eventBus.emit(
          const CallSessionInvalidatedAppEvent(
            CallSessionInvalidationReason.roleChanged,
          ),
        ),
        wait: const Duration(milliseconds: 10),
        expect: () => [
          isA<CallState>().having((s) => s.status, 'status', 'Disconnecting…'),
          isA<CallState>()
              .having((s) => s.localStreamActive, 'localStreamActive', isFalse)
              .having((s) => s.status, 'status', 'Disconnected.'),
        ],
      );
    });

    group('ToggleMicRequestedEvent', () {
      blocTest<CallBloc, CallState>(
        'toggles micEnabled from true to false',
        build: _makeBloc,
        seed: () => const CallState(localStreamActive: true),
        act: (bloc) => bloc.add(const ToggleMicRequestedEvent()),
        expect: () => [
          isA<CallState>().having((s) => s.micEnabled, 'micEnabled', isFalse),
        ],
      );

      late FakeRealtimeMediaSession mediaSession;
      blocTest<CallBloc, CallState>(
        'toggles micEnabled from false to true',
        setUp: () {
          mediaSession = FakeRealtimeMediaSession()..micEnabled = false;
        },
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () => const CallState(
          localStreamActive: true,
          micEnabled: false,
        ),
        act: (bloc) => bloc.add(const ToggleMicRequestedEvent()),
        expect: () => [
          isA<CallState>().having((s) => s.micEnabled, 'micEnabled', isTrue),
        ],
      );

      blocTest<CallBloc, CallState>(
        'ignores microphone commands before local media starts',
        build: _makeBloc,
        act: (bloc) => bloc.add(const ToggleMicRequestedEvent()),
        expect: () => <CallState>[],
      );

      blocTest<CallBloc, CallState>(
        'keeps microphone state when sender update fails',
        build: () => _makeBloc(
          mediaSession: FakeRealtimeMediaSession(
            microphoneToggleError: const MicrophonePublishingFailure(),
          ),
        ),
        seed: () => const CallState(
          localStreamActive: true,
        ),
        act: (bloc) => bloc.add(const ToggleMicRequestedEvent()),
        expect: () => [
          isA<CallState>()
              .having((s) => s.micEnabled, 'micEnabled', isTrue)
              .having(
                (s) => s.status,
                'status',
                'Could not update microphone. Try again.',
              ),
        ],
      );
    });

    group('ToggleCameraRequestedEvent', () {
      blocTest<CallBloc, CallState>(
        'toggles cameraEnabled from true to false',
        build: _makeBloc,
        seed: () => const CallState(localStreamActive: true),
        act: (bloc) => bloc.add(const ToggleCameraRequestedEvent()),
        expect: () => [
          isA<CallState>().having((s) => s.cameraEnabled, 'cameraEnabled', isFalse),
        ],
      );

      late FakeRealtimeMediaSession mediaSession;
      blocTest<CallBloc, CallState>(
        'toggles cameraEnabled from false to true',
        setUp: () {
          mediaSession = FakeRealtimeMediaSession()..cameraEnabled = false;
        },
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () => const CallState(
          localStreamActive: true,
          cameraEnabled: false,
        ),
        act: (bloc) => bloc.add(const ToggleCameraRequestedEvent()),
        expect: () => [
          isA<CallState>().having((s) => s.cameraEnabled, 'cameraEnabled', isTrue),
        ],
      );

      blocTest<CallBloc, CallState>(
        'ignores camera commands before local media starts',
        build: _makeBloc,
        act: (bloc) => bloc.add(const ToggleCameraRequestedEvent()),
        expect: () => <CallState>[],
      );

      blocTest<CallBloc, CallState>(
        'stops publishing camera without hiding the local preview',
        build: _makeBloc,
        seed: () => const CallState(localStreamActive: true),
        act: (bloc) => bloc.add(const ToggleCameraRequestedEvent()),
        expect: () => [
          isA<CallState>()
              .having((s) => s.cameraEnabled, 'cameraEnabled', isFalse)
              .having((s) => s.localStreamActive, 'localStreamActive', isTrue)
              .having((s) => s.showLocalPreviewPip, 'showLocalPreviewPip', isTrue),
        ],
      );

      blocTest<CallBloc, CallState>(
        'keeps camera state when sender update fails',
        build: () => _makeBloc(
          mediaSession: FakeRealtimeMediaSession(
            cameraToggleError: const CameraPublishingFailure(),
          ),
        ),
        seed: () => const CallState(localStreamActive: true),
        act: (bloc) => bloc.add(const ToggleCameraRequestedEvent()),
        expect: () => [
          isA<CallState>()
              .having((s) => s.cameraEnabled, 'cameraEnabled', isTrue)
              .having(
                (s) => s.status,
                'status',
                'Could not update camera. Try again.',
              ),
        ],
      );

      late FakeRealtimeMediaSession hiddenPreviewSession;
      blocTest<CallBloc, CallState>(
        'restarts capture for publishing while local preview stays hidden',
        setUp: () {
          hiddenPreviewSession = FakeRealtimeMediaSession()
            ..cameraEnabled = false
            ..localPreviewVisible = false
            ..videoCaptureActive = false;
        },
        build: () => _makeBloc(mediaSession: hiddenPreviewSession),
        seed: () => const CallState(
          localStreamActive: true,
          cameraEnabled: false,
          showLocalPreviewPip: false,
        ),
        act: (bloc) => bloc.add(const ToggleCameraRequestedEvent()),
        expect: () => [
          isA<CallState>()
              .having((s) => s.cameraEnabled, 'cameraEnabled', isTrue)
              .having(
                (s) => s.showLocalPreviewPip,
                'showLocalPreviewPip',
                isFalse,
              ),
        ],
        verify: (_) {
          expect(hiddenPreviewSession.videoCaptureActive, isTrue);
          expect(hiddenPreviewSession.localPreviewVisible, isFalse);
        },
      );
    });

    group('TogglePipRequestedEvent', () {
      blocTest<CallBloc, CallState>(
        'sets showLocalPreviewPip to false',
        build: _makeBloc,
        act: (bloc) => bloc.add(const TogglePipRequestedEvent(show: false)),
        expect: () => [
          isA<CallState>().having((s) => s.showLocalPreviewPip, 'showLocalPreviewPip', isFalse),
        ],
      );

      blocTest<CallBloc, CallState>(
        'sets showLocalPreviewPip to true from false',
        build: _makeBloc,
        seed: () => const CallState(showLocalPreviewPip: false),
        act: (bloc) => bloc.add(const TogglePipRequestedEvent(show: true)),
        expect: () => [
          isA<CallState>().having((s) => s.showLocalPreviewPip, 'showLocalPreviewPip', isTrue),
        ],
      );

      late FakeRealtimeMediaSession mediaSession;
      blocTest<CallBloc, CallState>(
        'releases video capture when publishing and preview are both off',
        setUp: () {
          mediaSession = FakeRealtimeMediaSession()..cameraEnabled = false;
        },
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () => const CallState(
          localStreamActive: true,
          cameraEnabled: false,
        ),
        act: (bloc) => bloc.add(
          const TogglePipRequestedEvent(show: false),
        ),
        expect: () => [
          isA<CallState>().having(
            (s) => s.showLocalPreviewPip,
            'showLocalPreviewPip',
            isFalse,
          ),
        ],
        verify: (_) {
          expect(mediaSession.localPreviewVisible, isFalse);
          expect(mediaSession.videoCaptureActive, isFalse);
        },
      );

      blocTest<CallBloc, CallState>(
        'restarts capture for preview while publishing stays off',
        setUp: () {
          mediaSession = FakeRealtimeMediaSession()
            ..cameraEnabled = false
            ..localPreviewVisible = false
            ..videoCaptureActive = false;
        },
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () => const CallState(
          localStreamActive: true,
          cameraEnabled: false,
          showLocalPreviewPip: false,
        ),
        act: (bloc) => bloc.add(
          const TogglePipRequestedEvent(show: true),
        ),
        expect: () => [
          isA<CallState>().having(
            (s) => s.showLocalPreviewPip,
            'showLocalPreviewPip',
            isTrue,
          ),
        ],
        verify: (_) {
          expect(mediaSession.localPreviewVisible, isTrue);
          expect(mediaSession.videoCaptureActive, isTrue);
          expect(mediaSession.cameraEnabled, isFalse);
        },
      );
    });

    group('PeerConnectionStateChanged', () {
      late FakeRealtimeMediaSession mediaSession;

      blocTest<CallBloc, CallState>(
        'sets viewerConnected to false on Failed',
        setUp: () => mediaSession = FakeRealtimeMediaSession(),
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () => const CallState(viewerConnected: true),
        act: (_) => mediaSession.emitConnectionState(
          RTCPeerConnectionState.RTCPeerConnectionStateFailed,
        ),
        expect: () => [
          isA<CallState>().having((s) => s.viewerConnected, 'viewerConnected', isFalse),
        ],
      );

      blocTest<CallBloc, CallState>(
        'sets viewerConnected to false on Disconnected',
        setUp: () => mediaSession = FakeRealtimeMediaSession(),
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () => const CallState(viewerConnected: true),
        act: (_) => mediaSession.emitConnectionState(
          RTCPeerConnectionState.RTCPeerConnectionStateDisconnected,
        ),
        expect: () => [
          isA<CallState>().having((s) => s.viewerConnected, 'viewerConnected', isFalse),
        ],
      );

      blocTest<CallBloc, CallState>(
        'does not clear viewerConnected on Connecting',
        setUp: () => mediaSession = FakeRealtimeMediaSession(),
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () => const CallState(viewerConnected: true),
        act: (_) => mediaSession.emitConnectionState(
          RTCPeerConnectionState.RTCPeerConnectionStateConnecting,
        ),
        expect: () => [
          isA<CallState>().having((s) => s.viewerConnected, 'viewerConnected', isTrue),
        ],
      );
    });

    group('RemoteTrackReceived', () {
      late FakeRealtimeMediaSession mediaSession;

      blocTest<CallBloc, CallState>(
        'sets remoteVideoAvailable to true and stores stream',
        setUp: () => mediaSession = FakeRealtimeMediaSession(),
        build: () => _makeBloc(mediaSession: mediaSession),
        act: (_) => mediaSession.emitRemoteStream(FakeMediaStream()),
        expect: () => [
          isA<CallState>()
              .having((s) => s.remoteVideoAvailable, 'remoteVideoAvailable', isTrue)
              .having((s) => s.remoteStream, 'remoteStream', isNotNull),
        ],
      );

      late FakeMediaStream localStream;
      blocTest<CallBloc, CallState>(
        'rejects a local stream reported as remote',
        setUp: () => mediaSession = FakeRealtimeMediaSession(),
        build: () => _makeBloc(mediaSession: mediaSession),
        seed: () {
          localStream = FakeMediaStream();

          return CallState(
            localStream: localStream,
            localStreamActive: true,
          );
        },
        act: (_) => mediaSession.emitRemoteStream(localStream),
        expect: () => <CallState>[],
      );

      late MockMediaStreamTrack sharedTrack;
      late FakeMediaStream localTrackStream;
      late FakeMediaStream candidateStream;
      blocTest<CallBloc, CallState>(
        'rejects a distinct stream carrying a local track',
        setUp: () {
          sharedTrack = MockMediaStreamTrack();
          when(() => sharedTrack.id).thenReturn('shared-track');
          when(() => sharedTrack.kind).thenReturn('video');
          localTrackStream = FakeMediaStream(
            id: 'local-stream',
            tracks: [sharedTrack],
          );
          candidateStream = FakeMediaStream(
            id: 'candidate-stream',
            tracks: [sharedTrack],
          );
        },
        build: () {
          mediaSession = FakeRealtimeMediaSession();

          return _makeBloc(mediaSession: mediaSession);
        },
        seed: () => CallState(
          localStream: localTrackStream,
          localStreamActive: true,
        ),
        act: (_) => mediaSession.emitRemoteStream(candidateStream),
        expect: () => <CallState>[],
      );
    });

    test('stores camera and microphone state received from the remote peer', () async {
      final mediaSession = FakeRealtimeMediaSession();
      final bloc = _makeBloc(mediaSession: mediaSession);

      mediaSession.emitRemoteMediaState(
        const RemoteMediaState(
          cameraEnabled: false,
          microphoneEnabled: false,
        ),
      );
      await expectLater(
        bloc.stream,
        emits(
          isA<CallState>()
              .having(
                (state) => state.remoteCameraEnabled,
                'remoteCameraEnabled',
                isFalse,
              )
              .having(
                (state) => state.remoteMicrophoneEnabled,
                'remoteMicrophoneEnabled',
                isFalse,
              ),
        ),
      );

      await bloc.close();
    });

    testWidgets('local peer invite waits for an explicit Connect action', (
      tester,
    ) async {
      const inviteUrl =
          'http://localhost:8080/home?intent=p2p&role=viewer'
          '&host=11111111111111111111111111111111&public=1';
      final eventBus = AppEventBus();
      final homeBloc = HomeBloc(
        eventBus: eventBus,
        initialRole: WebRtcRole.viewer,
      );
      final mediaSession = FakeRealtimeMediaSession();
      final callBloc = _makeBloc(
        eventBus: eventBus,
        mediaSession: mediaSession,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(create: (_) => homeBloc),
            BlocProvider<CallBloc>(create: (_) => callBloc),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CallControlsPanel(
                initialConnectionUrl: inviteUrl,
                onRoleChanged: _ignoreRoleChange,
                onSessionModeChanged: _ignoreSessionModeChange,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(homeBloc.state.webRtcRole, WebRtcRole.viewer);
      expect(find.text(inviteUrl), findsOneWidget);
      expect(callBloc.state, const CallState());
      expect(mediaSession.localStream, isNull);

      await tester.tap(find.text('Connect'));
      for (var attempt = 0; attempt < 10 && callBloc.state.connecting; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(callBloc.state.connecting, isFalse);
      expect(mediaSession.localStream, isNull);
      expect(
        callBloc.state.status,
        'Publisher and viewer must use different wallets.',
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('manual role change clears invite and reports route role', (
      tester,
    ) async {
      const inviteUrl =
          'http://localhost:8080/home?intent=p2p&role=viewer'
          '&host=host&public=1';
      final eventBus = AppEventBus();
      final homeBloc = HomeBloc(
        eventBus: eventBus,
        initialRole: WebRtcRole.viewer,
      );
      final callBloc = _makeBloc(eventBus: eventBus);
      WebRtcRole? routeRole;

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(create: (_) => homeBloc),
            BlocProvider<CallBloc>(create: (_) => callBloc),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CallControlsPanel(
                initialConnectionUrl: inviteUrl,
                onRoleChanged: (role) => routeRole = role,
                onSessionModeChanged: _ignoreSessionModeChange,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Publisher'));
      await tester.pumpAndSettle();
      expect(homeBloc.state.webRtcRole, WebRtcRole.publisher);
      expect(routeRole, WebRtcRole.publisher);

      await tester.tap(find.text('Viewer'));
      await tester.pumpAndSettle();
      expect(homeBloc.state.webRtcRole, WebRtcRole.viewer);
      expect(routeRole, WebRtcRole.viewer);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        isEmpty,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await eventBus.dispose();
    });

    testWidgets('route update replaces the external invite field', (
      tester,
    ) async {
      const firstInvite =
          'http://localhost:8080/home?intent=p2p&role=viewer'
          '&host=first&public=1';
      const secondInvite =
          'http://localhost:8080/home?intent=p2p&role=viewer'
          '&host=second&public=1';
      final eventBus = AppEventBus();
      final homeBloc = HomeBloc(
        eventBus: eventBus,
        initialRole: WebRtcRole.viewer,
      );
      final callBloc = _makeBloc(eventBus: eventBus);
      late StateSetter updatePanel;
      var invite = firstInvite;

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(create: (_) => homeBloc),
            BlocProvider<CallBloc>(create: (_) => callBloc),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  updatePanel = setState;

                  return CallControlsPanel(
                    initialConnectionUrl: invite,
                    onRoleChanged: (_) {},
                    onSessionModeChanged: _ignoreSessionModeChange,
                  );
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text(firstInvite), findsOneWidget);

      updatePanel(() => invite = secondInvite);
      await tester.pump();

      expect(find.text(firstInvite), findsNothing);
      expect(find.text(secondInvite), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await eventBus.dispose();
    });

    test('shows a precise message when the invite is already claimed', () async {
      final mediaSession = FakeRealtimeMediaSession();
      final bloc = _makeBloc(
        mediaSession: mediaSession,
        peerSignaling: const StubPeerSignaling(
          fetchError: PeerInviteClaimedException(),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(
        const ConnectAsViewerRequestedEvent(
          url:
              'http://localhost:8080/home?intent=p2p&role=viewer'
              '&host=host-wallet&public=1',
          rtcConfiguration: <String, dynamic>{},
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<CallState>()
              .having((state) => state.connecting, 'connecting', isFalse)
              .having(
                (state) => state.status,
                'status',
                'This invite has already been claimed. '
                    'Ask the publisher to regenerate it.',
              ),
        ),
      );
      expect(mediaSession.localStream, isNull);
    });

    testWidgets('publisher invite exposes copy and regeneration actions', (
      tester,
    ) async {
      const inviteUrl =
          'http://localhost:8080/home?intent=p2p&role=viewer'
          '&host=host&public=1';
      String? copiedUrl;
      var regenerationRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublisherControls(
              goingLive: false,
              connectionUrl: inviteUrl,
              onGoLive: () {},
              onCopyInvite: (url) => copiedUrl = url,
              onRegenerateInvite: () => regenerationRequested = true,
            ),
          ),
        ),
      );

      expect(find.text(inviteUrl), findsOneWidget);
      expect(find.byTooltip('Copy invite link'), findsOneWidget);
      expect(find.byTooltip('Regenerate invite link'), findsOneWidget);

      await tester.tap(find.byTooltip('Copy invite link'));
      await tester.tap(find.byTooltip('Regenerate invite link'));

      expect(copiedUrl, inviteUrl);
      expect(regenerationRequested, isTrue);
    });
  });
}
