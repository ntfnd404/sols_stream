import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_media/realtime_media.dart';
import 'package:sols_stream/feature/call/bloc/call_bloc.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';
import 'package:sols_stream/feature/home/view/widgets/stream_viewport.dart';
import 'package:sols_stream/feature/home/view/widgets/viewport_placeholder.dart';
import 'package:sols_stream/feature/home/view/widgets/viewport_section.dart';

class CallViewportPanel extends StatefulWidget {
  const CallViewportPanel({super.key});

  @override
  State<CallViewportPanel> createState() => _CallViewportPanelState();
}

class _CallViewportPanelState extends State<CallViewportPanel> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _renderersReady = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    if (!mounted) return;

    _renderersReady.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _syncRenderers(context.read<CallBloc>().state);
    });
  }

  void _syncRenderers(CallState state) {
    if (!_renderersReady.value) return;
    _localRenderer.srcObject = state.localStream;
    _remoteRenderer.srcObject = state.remoteStream;
  }

  @override
  void dispose() {
    _renderersReady.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<CallBloc, CallState>(
    listenWhen: (prev, curr) =>
        prev.localStream != curr.localStream ||
        prev.remoteStream != curr.remoteStream ||
        prev.cameraEnabled != curr.cameraEnabled ||
        prev.showLocalPreviewPip != curr.showLocalPreviewPip,
    listener: (context, state) => _syncRenderers(state),
    child: BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) => prev.webRtcRole != curr.webRtcRole,
      builder: (context, homeState) => BlocBuilder<CallBloc, CallState>(
        builder: (context, callState) => ValueListenableBuilder<bool>(
          valueListenable: _renderersReady,
          builder: (context, ready, _) => ViewportSection(
            rtcState: callState.rtcState,
            transportMode: TransportMode.webrtc,
            micEnabled: callState.micEnabled,
            cameraEnabled: callState.cameraEnabled,
            localStreamActive: callState.localStreamActive,
            remoteVideoAvailable: callState.remoteVideoAvailable,
            showLocalPreviewPip: callState.showLocalPreviewPip,
            onToggleMic: () => context.read<CallBloc>().add(const ToggleMicRequestedEvent()),
            onToggleCamera: () => context.read<CallBloc>().add(const ToggleCameraRequestedEvent()),
            onTogglePip: (value) => context.read<CallBloc>().add(TogglePipRequestedEvent(show: value)),
            status: callState.status,
            diagnostics: callState.rtcDiagnostics,
            viewport: ready
                ? StreamViewport(
                    transportMode: TransportMode.webrtc,
                    webRtcRole: homeState.webRtcRole,
                    videoController: null,
                    localStreamActive: callState.localStreamActive,
                    remoteVideoAvailable: callState.remoteVideoAvailable,
                    remoteCameraEnabled: callState.remoteCameraEnabled,
                    remoteMicrophoneEnabled: callState.remoteMicrophoneEnabled,
                    showLocalPreviewPip: callState.showLocalPreviewPip,
                    localRenderer: _localRenderer,
                    remoteRenderer: _remoteRenderer,
                  )
                : const ViewportPlaceholder(
                    title: 'WebRTC',
                    subtitle: 'Preparing video renderers.',
                  ),
          ),
        ),
      ),
    ),
  );
}
