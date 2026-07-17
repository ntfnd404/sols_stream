import 'dart:async';

import 'package:ephemeral_bloc/ephemeral_bloc.dart';
import 'package:flutter/material.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/hls_controls.dart';
import 'package:sols_stream/feature/home/view/widgets/stream_viewport.dart';
import 'package:sols_stream/feature/home/view/widgets/viewport_section.dart';
import 'package:streaming/streaming.dart';

typedef HlsSectionBuilder =
    Widget Function(
      BuildContext context,
      Widget viewport,
      Widget controls,
    );

class HlsSection extends StatefulWidget {
  const HlsSection({
    super.key,
    required this.builder,
  });

  final HlsSectionBuilder builder;

  @override
  State<HlsSection> createState() => _HlsSectionState();
}

class _HlsSectionState extends State<HlsSection> {
  static _HlsSectionState _of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_InheritedHlsSection>();
    if (scope == null) {
      throw StateError('HlsSection not found in widget tree');
    }

    return scope.hls;
  }

  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _playback = HlsPlaybackController();

  Future<void> _playHls() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _playback.setEmptyUrlStatus();

      return;
    }

    await _playback.play(
      HlsSource(
        uri: Uri.parse(url),
        auth: HlsAuthConfig(
          username: _usernameController.text,
          password: _passwordController.text,
          bearerToken: _tokenController.text,
        ),
      ),
    );
  }

  Future<void> _stopHls() => _playback.stop();

  void _onHomeAction(BuildContext context, HomeAction action) {
    switch (action) {
      case TransportModeChangingAction(:final newMode):
        if (newMode == TransportMode.webrtc) {
          unawaited(_playback.stop(status: null));
        }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    _playback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EphemeralBlocListener<HomeBloc, HomeState, HomeAction>(
    listener: _onHomeAction,
    child: _InheritedHlsSection(
      hls: this,
      child: Builder(
        builder: (context) => widget.builder(
          context,
          const HlsViewportPanel(),
          const HlsControlsPanel(),
        ),
      ),
    ),
  );
}

class HlsViewportPanel extends StatelessWidget {
  const HlsViewportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final hls = _HlsSectionState._of(context);

    return AnimatedBuilder(
      animation: hls._playback,
      builder: (context, _) => ViewportSection(
        rtcState: 'HLS',
        transportMode: TransportMode.hls,
        micEnabled: false,
        cameraEnabled: false,
        localStreamActive: false,
        remoteVideoAvailable: false,
        showLocalPreviewPip: false,
        onToggleMic: () {},
        onToggleCamera: () {},
        onTogglePip: (_) {},
        status: hls._playback.status,
        viewport: StreamViewport(
          transportMode: TransportMode.hls,
          webRtcRole: WebRtcRole.publisher,
          videoController: hls._playback.videoController,
          localStreamActive: false,
          remoteVideoAvailable: false,
          remoteCameraEnabled: false,
          remoteMicrophoneEnabled: false,
          showLocalPreviewPip: false,
          localRenderer: null,
          remoteRenderer: null,
        ),
      ),
    );
  }
}

class HlsControlsPanel extends StatelessWidget {
  const HlsControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final hls = _HlsSectionState._of(context);

    return AnimatedBuilder(
      animation: hls._playback,
      builder: (context, _) => HlsControls(
        hlsSupported: hls._playback.isSupported,
        isStartingHls: hls._playback.isStarting,
        urlController: hls._urlController,
        usernameController: hls._usernameController,
        passwordController: hls._passwordController,
        tokenController: hls._tokenController,
        onPlay: hls._playHls,
        onStop: hls._stopHls,
      ),
    );
  }
}

class _InheritedHlsSection extends InheritedWidget {
  const _InheritedHlsSection({
    required this.hls,
    required super.child,
  });

  final _HlsSectionState hls;

  @override
  bool updateShouldNotify(_InheritedHlsSection oldWidget) => hls != oldWidget.hls;
}
