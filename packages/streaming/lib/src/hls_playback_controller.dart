import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:streaming/src/hls_source.dart';
import 'package:video_player/video_player.dart';

final class HlsPlaybackController extends ChangeNotifier {
  VideoPlayerController? _videoController;
  bool _isStarting = false;
  String? _status;

  VideoPlayerController? get videoController => _videoController;
  bool get isStarting => _isStarting;
  String? get status => _status;

  bool get isSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  void setEmptyUrlStatus() => _setStatus('Stream URL is empty.');

  Future<void> play(HlsSource source) async {
    if (!isSupported) {
      _setStatus('HLS not supported on this platform.');

      return;
    }

    _setStarting(true, status: 'Starting HLS playback...');
    try {
      await stop(status: null);
      final controller = VideoPlayerController.networkUrl(
        source.uri,
        httpHeaders: source.auth.toHeaders(),
      );
      await controller.initialize();
      await controller.play();
      unawaited(controller.setLooping(false));
      _videoController = controller;
      _setStarting(false, status: 'HLS playback started.');
    } on Exception {
      _setStarting(false, status: 'HLS playback failed. Check the stream URL and credentials.');
    }
  }

  Future<void> stop({String? status = 'HLS stopped.'}) async {
    final controller = _videoController;
    _videoController = null;
    await controller?.dispose();
    if (status != null) _setStatus(status);
    notifyListeners();
  }

  @override
  void dispose() {
    final controller = _videoController;
    _videoController = null;
    unawaited(controller?.dispose());
    super.dispose();
  }

  void _setStarting(bool value, {required String? status}) {
    _isStarting = value;
    _status = status;
    notifyListeners();
  }

  void _setStatus(String? value) {
    _status = value;
    notifyListeners();
  }
}
