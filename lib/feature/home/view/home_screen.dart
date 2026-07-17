import 'package:ephemeral_bloc/ephemeral_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sols_stream/feature/call/bloc/call_bloc.dart';
import 'package:sols_stream/feature/call/di/call_scope.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/di/home_scope.dart';
import 'package:sols_stream/feature/home/model/home_launch_config.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/home_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.sessionMode,
    required this.webRtcRole,
    this.initialConnectionUrl,
    required this.onRoleChanged,
    required this.onSessionModeChanged,
  });

  final SessionMode sessionMode;
  final WebRtcRole webRtcRole;
  final String? initialConnectionUrl;
  final ValueChanged<WebRtcRole> onRoleChanged;
  final ValueChanged<SessionMode> onSessionModeChanged;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<HomeBloc>(
        create: (context) => HomeScope.createBloc(
          context,
          config: HomeLaunchConfig(
            sessionMode: sessionMode,
            webRtcRole: webRtcRole,
          ),
        ),
      ),
      const BlocProvider<CallBloc>(
        create: CallScope.createBloc,
      ),
    ],
    child: _HomeRouteContent(
      sessionMode: sessionMode,
      webRtcRole: webRtcRole,
      initialConnectionUrl: initialConnectionUrl,
      onRoleChanged: onRoleChanged,
      onSessionModeChanged: onSessionModeChanged,
    ),
  );
}

class _HomeRouteContent extends StatefulWidget {
  const _HomeRouteContent({
    required this.sessionMode,
    required this.webRtcRole,
    required this.initialConnectionUrl,
    required this.onRoleChanged,
    required this.onSessionModeChanged,
  });

  final SessionMode sessionMode;
  final WebRtcRole webRtcRole;
  final String? initialConnectionUrl;
  final ValueChanged<WebRtcRole> onRoleChanged;
  final ValueChanged<SessionMode> onSessionModeChanged;

  @override
  State<_HomeRouteContent> createState() => _HomeRouteContentState();
}

class _HomeRouteContentState extends State<_HomeRouteContent> {
  @override
  void didUpdateWidget(_HomeRouteContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.webRtcRole != widget.webRtcRole) {
      context.read<HomeBloc>().add(WebRtcRoleChangedEvent(widget.webRtcRole));
    }
    if (oldWidget.sessionMode != widget.sessionMode) {
      context.read<HomeBloc>().add(
        SessionModeChangedEvent(widget.sessionMode),
      );
    }
  }

  @override
  Widget build(BuildContext context) => EphemeralBlocListener<CallBloc, CallState, CallAction>(
    listener: (context, action) {
      switch (action) {
        case ShowStatusMessageAction(:final message):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
      }
    },
    child: HomeView(
      initialConnectionUrl: widget.initialConnectionUrl,
      onRoleChanged: widget.onRoleChanged,
      onSessionModeChanged: widget.onSessionModeChanged,
    ),
  );
}
