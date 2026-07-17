import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mocktail/mocktail.dart';

final class MockDataChannel extends Mock implements RTCDataChannel {
  @override
  void Function(RTCDataChannelState state)? onDataChannelState;

  @override
  void Function(RTCDataChannelMessage data)? onMessage;
}
