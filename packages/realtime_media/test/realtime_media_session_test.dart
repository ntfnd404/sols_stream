import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:realtime_media/realtime_media.dart';

import 'mocks/mock_data_channel.dart';
import 'mocks/mock_media_stream.dart';
import 'mocks/mock_media_stream_track.dart';
import 'mocks/mock_peer_connection.dart';
import 'mocks/mock_rtp_sender.dart';

void main() {
  late MockMediaStream localStream;
  late MockMediaStreamTrack audioTrack;
  late MockMediaStreamTrack videoTrack;
  late MockRtpSender audioSender;
  late MockRtpSender videoSender;
  late MockPeerConnection peerConnection;
  late MockDataChannel dataChannel;

  setUpAll(() {
    registerFallbackValue(RTCSessionDescription('v=0', 'offer'));
    registerFallbackValue(RTCDataChannelInit());
    registerFallbackValue(RTCDataChannelMessage(''));
  });

  setUp(() {
    localStream = MockMediaStream();
    audioTrack = MockMediaStreamTrack();
    videoTrack = MockMediaStreamTrack();
    audioSender = MockRtpSender();
    videoSender = MockRtpSender();
    peerConnection = MockPeerConnection();
    dataChannel = MockDataChannel();

    when(() => localStream.id).thenReturn('local-stream');
    when(() => localStream.getTracks()).thenReturn([audioTrack, videoTrack]);
    when(() => localStream.getAudioTracks()).thenReturn([audioTrack]);
    when(() => localStream.getVideoTracks()).thenReturn([videoTrack]);
    when(() => localStream.removeTrack(audioTrack)).thenAnswer((_) async {});
    when(() => localStream.removeTrack(videoTrack)).thenAnswer((_) async {});
    when(() => localStream.dispose()).thenAnswer((_) async {});

    when(() => audioTrack.id).thenReturn('local-audio');
    when(() => audioTrack.kind).thenReturn('audio');
    when(() => audioTrack.stop()).thenAnswer((_) async {});
    when(() => videoTrack.id).thenReturn('local-video');
    when(() => videoTrack.kind).thenReturn('video');
    when(() => videoTrack.stop()).thenAnswer((_) async {});

    when(() => audioSender.replaceTrack(null)).thenAnswer((_) async {});
    when(() => videoSender.replaceTrack(null)).thenAnswer((_) async {});
    when(() => peerConnection.getSenders()).thenAnswer((_) async => []);
    when(
      () => peerConnection.addTrack(audioTrack, localStream),
    ).thenAnswer((_) async => audioSender);
    when(
      () => peerConnection.addTrack(videoTrack, localStream),
    ).thenAnswer((_) async => videoSender);
    when(
      () => peerConnection.createOffer(any()),
    ).thenAnswer((_) async => RTCSessionDescription('v=0', 'offer'));
    when(
      () => peerConnection.setLocalDescription(any()),
    ).thenAnswer((_) async {});
    when(
      () => peerConnection.getLocalDescription(),
    ).thenAnswer(
      (_) async => RTCSessionDescription('v=0', 'offer'),
    );
    when(() => peerConnection.iceGatheringState).thenReturn(
      RTCIceGatheringState.RTCIceGatheringStateComplete,
    );
    when(
      () => peerConnection.createDataChannel(any(), any()),
    ).thenAnswer((_) async => dataChannel);
    when(() => peerConnection.close()).thenAnswer((_) async {});
    when(() => dataChannel.close()).thenAnswer((_) async {});
    when(() => dataChannel.state).thenReturn(
      RTCDataChannelState.RTCDataChannelConnecting,
    );
    when(() => dataChannel.send(any())).thenAnswer((_) async {});
  });

  test(
    'Camera off detaches outgoing video but keeps local preview capture',
    () async {
      final session = RealtimeMediaSession(
        userMediaFactory: (_) async => localStream,
        peerConnectionFactory: (_) async => peerConnection,
      );
      addTearDown(session.close);

      await session.startLocalMedia();
      await session.createOffer(const <String, Object?>{});

      expect(await session.toggleCamera(), isFalse);
      verify(() => videoSender.replaceTrack(null)).called(1);
      verifyNever(videoTrack.stop);
      expect(session.localStream, same(localStream));
    },
  );

  test('failed Camera on releases the replacement capture', () async {
    final videoSource = MockMediaStream();
    final replacementVideoTrack = MockMediaStreamTrack();
    var mediaRequest = 0;

    when(() => videoSource.getVideoTracks()).thenReturn(
      [replacementVideoTrack],
    );
    when(() => videoSource.dispose()).thenAnswer((_) async {});
    when(() => replacementVideoTrack.id).thenReturn('replacement-video');
    when(() => replacementVideoTrack.kind).thenReturn('video');
    when(
      replacementVideoTrack.stop,
    ).thenThrow(Exception('replacement video stop failed'));
    when(
      () => localStream.addTrack(replacementVideoTrack),
    ).thenAnswer((_) async {});
    when(
      () => localStream.removeTrack(replacementVideoTrack),
    ).thenAnswer((_) async {});
    when(
      () => videoSender.replaceTrack(replacementVideoTrack),
    ).thenThrow(Exception('sender rejected replacement'));

    final session = RealtimeMediaSession(
      userMediaFactory: (_) async {
        mediaRequest += 1;

        return mediaRequest == 1 ? localStream : videoSource;
      },
      peerConnectionFactory: (_) async => peerConnection,
    );
    addTearDown(session.close);

    await session.startLocalMedia();
    await session.createOffer(const <String, dynamic>{});
    expect(await session.toggleCamera(), isFalse);
    await session.setLocalPreviewVisible(false);

    await expectLater(
      session.toggleCamera(),
      throwsA(isA<CameraPublishingFailure>()),
    );
    verify(replacementVideoTrack.stop).called(1);
    verify(() => localStream.removeTrack(replacementVideoTrack)).called(1);
    verify(() => videoSource.dispose()).called(1);
  });

  test(
    'Mic off detaches and stops capture; Mic on restores a new track',
    () async {
      final audioSource = MockMediaStream();
      final replacementAudioTrack = MockMediaStreamTrack();
      var mediaRequest = 0;

      when(() => audioSource.getAudioTracks()).thenReturn(
        [replacementAudioTrack],
      );
      when(() => audioSource.dispose()).thenAnswer((_) async {});
      when(() => replacementAudioTrack.id).thenReturn('replacement-audio');
      when(() => replacementAudioTrack.kind).thenReturn('audio');
      when(() => replacementAudioTrack.stop()).thenAnswer((_) async {});
      when(
        () => localStream.addTrack(replacementAudioTrack),
      ).thenAnswer((_) async {});
      when(
        () => audioSender.replaceTrack(replacementAudioTrack),
      ).thenAnswer((_) async {});

      final session = RealtimeMediaSession(
        userMediaFactory: (_) async {
          mediaRequest += 1;

          return mediaRequest == 1 ? localStream : audioSource;
        },
        peerConnectionFactory: (_) async => peerConnection,
      );
      addTearDown(session.close);

      await session.startLocalMedia();
      await session.createOffer(const <String, Object?>{});

      expect(await session.toggleMic(), isFalse);
      verify(() => audioSender.replaceTrack(null)).called(1);
      verify(audioTrack.stop).called(1);
      verify(() => localStream.removeTrack(audioTrack)).called(1);

      expect(await session.toggleMic(), isTrue);
      verify(() => localStream.addTrack(replacementAudioTrack)).called(1);
      verify(
        () => audioSender.replaceTrack(replacementAudioTrack),
      ).called(1);
    },
  );

  test('failed Mic on releases the replacement capture', () async {
    final audioSource = MockMediaStream();
    final replacementAudioTrack = MockMediaStreamTrack();
    var mediaRequest = 0;

    when(() => audioSource.getAudioTracks()).thenReturn(
      [replacementAudioTrack],
    );
    when(() => audioSource.dispose()).thenAnswer((_) async {});
    when(() => replacementAudioTrack.id).thenReturn('replacement-audio');
    when(() => replacementAudioTrack.kind).thenReturn('audio');
    when(
      replacementAudioTrack.stop,
    ).thenThrow(Exception('replacement audio stop failed'));
    when(
      () => localStream.addTrack(replacementAudioTrack),
    ).thenAnswer((_) async {});
    when(
      () => localStream.removeTrack(replacementAudioTrack),
    ).thenAnswer((_) async {});
    when(
      () => audioSender.replaceTrack(replacementAudioTrack),
    ).thenThrow(Exception('sender rejected replacement'));

    final session = RealtimeMediaSession(
      userMediaFactory: (_) async {
        mediaRequest += 1;

        return mediaRequest == 1 ? localStream : audioSource;
      },
      peerConnectionFactory: (_) async => peerConnection,
    );
    addTearDown(session.close);

    await session.startLocalMedia();
    await session.createOffer(const <String, Object?>{});
    expect(await session.toggleMic(), isFalse);

    await expectLater(
      session.toggleMic(),
      throwsA(isA<MicrophonePublishingFailure>()),
    );
    verify(replacementAudioTrack.stop).called(1);
    verify(() => localStream.removeTrack(replacementAudioTrack)).called(1);
    verify(() => audioSource.dispose()).called(1);
  });

  test('failed microphone stop still removes capture and keeps sender detached', () async {
    when(
      audioTrack.stop,
    ).thenThrow(Exception('microphone stop failed'));
    when(
      () => audioSender.replaceTrack(audioTrack),
    ).thenAnswer((_) async {});

    final session = RealtimeMediaSession(
      userMediaFactory: (_) async => localStream,
      peerConnectionFactory: (_) async => peerConnection,
    );
    addTearDown(session.close);

    await session.startLocalMedia();
    await session.createOffer(const <String, dynamic>{});

    await expectLater(
      session.toggleMic(),
      throwsA(isA<MicrophonePublishingFailure>()),
    );
    verify(() => audioSender.replaceTrack(null)).called(1);
    verify(() => localStream.removeTrack(audioTrack)).called(1);
    verifyNever(() => audioSender.replaceTrack(audioTrack));
    expect(session.microphonePublishingEnabled, isFalse);
    when(audioTrack.stop).thenAnswer((_) async {});
  });

  test(
    'Camera off with hidden preview reports stop failure after removing capture',
    () async {
      final session = RealtimeMediaSession(
        userMediaFactory: (_) async => localStream,
        peerConnectionFactory: (_) async => peerConnection,
      );
      addTearDown(session.close);

      await session.startLocalMedia();
      await session.createOffer(const <String, dynamic>{});
      await session.setLocalPreviewVisible(false);
      when(videoTrack.stop).thenThrow(Exception('camera stop failed'));

      await expectLater(
        session.toggleCamera(),
        throwsA(isA<CameraPublishingFailure>()),
      );

      verify(() => videoSender.replaceTrack(null)).called(1);
      verify(() => localStream.removeTrack(videoTrack)).called(1);
      expect(session.cameraPublishingEnabled, isFalse);
      expect(session.isLocalPreviewVisible, isFalse);
      when(videoTrack.stop).thenAnswer((_) async {});
    },
  );

  test('remote media-state updates camera and microphone together', () async {
    final session = RealtimeMediaSession(
      userMediaFactory: (_) async => localStream,
      peerConnectionFactory: (_) async => peerConnection,
    );
    addTearDown(session.close);

    await session.startLocalMedia();
    await session.createOffer(const <String, Object?>{});
    final received = session.remoteMediaStates.first;

    dataChannel.onMessage?.call(
      RTCDataChannelMessage(
        jsonEncode({
          'type': 'media-state',
          'cameraEnabled': false,
          'microphoneEnabled': false,
        }),
      ),
    );

    expect(
      await received,
      isA<RemoteMediaState>()
          .having((state) => state.cameraEnabled, 'cameraEnabled', isFalse)
          .having((state) => state.microphoneEnabled, 'microphoneEnabled', isFalse),
    );
  });

  test('opening control channel sends current camera and microphone state', () async {
    final session = RealtimeMediaSession(
      userMediaFactory: (_) async => localStream,
      peerConnectionFactory: (_) async => peerConnection,
    );
    addTearDown(session.close);

    await session.startLocalMedia();
    await session.createOffer(const <String, Object?>{});
    when(() => dataChannel.state).thenReturn(
      RTCDataChannelState.RTCDataChannelOpen,
    );

    dataChannel.onDataChannelState?.call(
      RTCDataChannelState.RTCDataChannelOpen,
    );
    await Future<void>.delayed(Duration.zero);

    final message = verify(() => dataChannel.send(captureAny())).captured.single as RTCDataChannelMessage;
    expect(
      jsonDecode(message.text),
      {
        'type': 'media-state',
        'cameraEnabled': true,
        'microphoneEnabled': true,
      },
    );
  });

  test('Mic off sends disabled microphone state without disabling camera', () async {
    final session = RealtimeMediaSession(
      userMediaFactory: (_) async => localStream,
      peerConnectionFactory: (_) async => peerConnection,
    );
    addTearDown(session.close);

    await session.startLocalMedia();
    await session.createOffer(const <String, Object?>{});
    when(() => dataChannel.state).thenReturn(
      RTCDataChannelState.RTCDataChannelOpen,
    );

    expect(await session.toggleMic(), isFalse);
    await Future<void>.delayed(Duration.zero);

    final message = verify(() => dataChannel.send(captureAny())).captured.single as RTCDataChannelMessage;
    expect(
      jsonDecode(message.text),
      {
        'type': 'media-state',
        'cameraEnabled': true,
        'microphoneEnabled': false,
      },
    );
    verify(() => audioSender.replaceTrack(null)).called(1);
    verify(audioTrack.stop).called(1);
  });
}
