sealed class RealtimeMediaException implements Exception {
  final String message;

  const RealtimeMediaException(this.message);

  @override
  String toString() => message;
}

final class LocalMediaStartFailure extends RealtimeMediaException {
  const LocalMediaStartFailure() : super('Failed to start local media.');
}

final class PeerConnectionFailure extends RealtimeMediaException {
  const PeerConnectionFailure() : super('Failed to create peer connection.');
}

final class CameraPublishingFailure extends RealtimeMediaException {
  const CameraPublishingFailure() : super('Failed to update camera publishing state.');
}

final class MicrophonePublishingFailure extends RealtimeMediaException {
  const MicrophonePublishingFailure() : super('Failed to update microphone publishing state.');
}

final class SdpParseFailure extends RealtimeMediaException {
  const SdpParseFailure() : super('Invalid session description.');
}

final class SdpApplicationFailure extends RealtimeMediaException {
  const SdpApplicationFailure() : super('Failed to apply session description.');
}
