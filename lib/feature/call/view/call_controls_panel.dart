import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sols_stream/feature/call/bloc/call_bloc.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/publisher_controls.dart';
import 'package:sols_stream/feature/home/view/widgets/stun_turn_section.dart';
import 'package:sols_stream/feature/home/view/widgets/viewer_controls.dart';
import 'package:sols_stream/feature/home/view/widgets/webrtc_controls.dart';

class CallControlsPanel extends StatefulWidget {
  const CallControlsPanel({
    super.key,
    this.initialConnectionUrl,
    required this.onRoleChanged,
    required this.onSessionModeChanged,
  });

  final String? initialConnectionUrl;
  final ValueChanged<WebRtcRole> onRoleChanged;
  final ValueChanged<SessionMode> onSessionModeChanged;

  @override
  State<CallControlsPanel> createState() => _CallControlsPanelState();
}

class _CallControlsPanelState extends State<CallControlsPanel> {
  final _stunTurnUrlsController = TextEditingController(
    text: 'stun:stun.l.google.com:19302',
  );
  final _turnUsernameController = TextEditingController();
  final _turnPasswordController = TextEditingController();
  late final TextEditingController _connectionLinkController;

  @override
  void initState() {
    super.initState();
    final initialConnectionUrl = widget.initialConnectionUrl ?? _browserConnectionUrl();
    _connectionLinkController = TextEditingController(
      text: initialConnectionUrl,
    );
  }

  Map<String, dynamic> _rtcConfiguration() {
    final urls = _splitLines(_stunTurnUrlsController.text);
    final iceServers = <Map<String, dynamic>>[];
    for (final url in urls) {
      final server = <String, dynamic>{'urls': url};
      if (url.startsWith('turn:') || url.startsWith('turns:')) {
        if (_turnUsernameController.text.trim().isNotEmpty) {
          server['username'] = _turnUsernameController.text.trim();
        }
        if (_turnPasswordController.text.trim().isNotEmpty) {
          server['credential'] = _turnPasswordController.text.trim();
        }
      }
      iceServers.add(server);
    }

    return {'iceServers': iceServers, 'sdpSemantics': 'unified-plan'};
  }

  List<String> _splitLines(String input) =>
      input.split(RegExp(r'[\n,]')).map((value) => value.trim()).where((value) => value.isNotEmpty).toList();

  Future<void> _copyInvite(String connectionUrl) async {
    await Clipboard.setData(ClipboardData(text: connectionUrl));
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Invite link copied.')));
  }

  String? _browserConnectionUrl() {
    final uri = Uri.base;
    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    final host = uri.queryParameters['host'];
    if (!isHttp || host == null || host.isEmpty) return null;

    return uri.toString();
  }

  @override
  void didUpdateWidget(CallControlsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialConnectionUrl == widget.initialConnectionUrl) return;

    _connectionLinkController.text = widget.initialConnectionUrl ?? '';
  }

  @override
  void dispose() {
    _stunTurnUrlsController.dispose();
    _turnUsernameController.dispose();
    _turnPasswordController.dispose();
    _connectionLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, homeState) => BlocBuilder<CallBloc, CallState>(
      builder: (context, callState) => WebRtcControls(
        role: homeState.webRtcRole,
        sessionMode: homeState.sessionMode,
        onRoleChanged: (role) {
          _connectionLinkController.clear();
          context.read<HomeBloc>().add(WebRtcRoleChangedEvent(role));
          widget.onRoleChanged(role);
        },
        onSessionModeChanged: (mode) {
          _connectionLinkController.clear();
          context.read<HomeBloc>().add(SessionModeChangedEvent(mode));
          widget.onSessionModeChanged(mode);
        },
        hasLocalStream: callState.localStreamActive,
        onDisconnect: () => context.read<CallBloc>().add(const DisconnectRequestedEvent()),
        publisherControls: PublisherControls(
          goingLive: callState.goingLive,
          connectionUrl: callState.hostSession?.connectionUrl,
          onGoLive: () => context.read<CallBloc>().add(
            GoLiveRequestedEvent(
              rtcConfiguration: _rtcConfiguration(),
            ),
          ),
          onCopyInvite: _copyInvite,
          onRegenerateInvite: () => context.read<CallBloc>().add(
            RegenerateInviteRequestedEvent(
              rtcConfiguration: _rtcConfiguration(),
            ),
          ),
        ),
        viewerControls: ViewerControls(
          connectionLinkController: _connectionLinkController,
          connecting: callState.connecting,
          connected: callState.viewerConnected,
          onConnect: () => context.read<CallBloc>().add(
            ConnectAsViewerRequestedEvent(
              url: _connectionLinkController.text,
              rtcConfiguration: _rtcConfiguration(),
            ),
          ),
        ),
        stunTurnSection: StunTurnSection(
          urlsController: _stunTurnUrlsController,
          usernameController: _turnUsernameController,
          passwordController: _turnPasswordController,
        ),
      ),
    ),
  );
}
