import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:realtime_media/src/realtime_media_session_controller.dart';

typedef UserMediaFactory = Future<MediaStream> Function(Map<String, dynamic> constraints);
typedef PeerConnectionFactory = Future<RTCPeerConnection> Function(RtcConfiguration configuration);
