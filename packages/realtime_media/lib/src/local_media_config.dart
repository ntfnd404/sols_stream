final class LocalMediaConfig {
  final bool audio;
  final Map<String, Object?> video;

  const LocalMediaConfig({
    this.audio = true,
    this.video = const {
      'width': {'ideal': 1280},
      'height': {'ideal': 720},
      'frameRate': {'ideal': 30},
      'facingMode': 'user',
    },
  });

  Map<String, Object?> toConstraints() => {
    'audio': audio,
    'video': video,
  };
}
