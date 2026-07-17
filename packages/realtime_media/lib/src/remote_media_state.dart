import 'package:flutter/foundation.dart';

@immutable
final class RemoteMediaState {
  final bool cameraEnabled;
  final bool microphoneEnabled;

  const RemoteMediaState({
    this.cameraEnabled = true,
    this.microphoneEnabled = true,
  });

  RemoteMediaState copyWith({
    bool? cameraEnabled,
    bool? microphoneEnabled,
  }) => RemoteMediaState(
    cameraEnabled: cameraEnabled ?? this.cameraEnabled,
    microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
  );
}
