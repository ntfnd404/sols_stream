import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sols_stream/feature/call/view/call_controls_panel.dart';
import 'package:sols_stream/feature/call/view/call_viewport_panel.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';
import 'package:sols_stream/feature/home/view/widgets/control_section.dart';
import 'package:sols_stream/feature/home/view/widgets/hls_section.dart';
import 'package:sols_stream/feature/home/view/widgets/panel.dart';
import 'package:sols_stream/feature/home/view/widgets/wallet_balance_tile.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    this.initialConnectionUrl,
    required this.onRoleChanged,
    required this.onSessionModeChanged,
  });

  final String? initialConnectionUrl;
  final ValueChanged<WebRtcRole> onRoleChanged;
  final ValueChanged<SessionMode> onSessionModeChanged;

  Widget _controls(
    BuildContext context,
    HomeState homeState,
    Widget hlsControls, {
    bool scrollable = true,
    String? initialConnectionUrl,
    required ValueChanged<WebRtcRole> onRoleChanged,
    required ValueChanged<SessionMode> onSessionModeChanged,
  }) => ControlSection(
    transportMode: homeState.transportMode,
    onTransportChanged: (mode) => context.read<HomeBloc>().add(TransportModeChangedEvent(mode)),
    webRtcControls: CallControlsPanel(
      initialConnectionUrl: initialConnectionUrl,
      onRoleChanged: onRoleChanged,
      onSessionModeChanged: onSessionModeChanged,
    ),
    hlsControls: hlsControls,
    walletTile: const WalletBalanceTile(),
    scrollable: scrollable,
  );

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, homeState) => HlsSection(
      builder: (context, hlsViewport, hlsControls) {
        final viewportContent = switch (homeState.transportMode) {
          TransportMode.webrtc => const CallViewportPanel(),
          TransportMode.hls => hlsViewport,
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('sols.stream'),
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1100;

                if (wide) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Panel(
                            title: 'Viewport',
                            child: viewportContent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Panel(
                            title: 'Connection',
                            child: _controls(
                              context,
                              homeState,
                              hlsControls,
                              initialConnectionUrl: initialConnectionUrl,
                              onRoleChanged: onRoleChanged,
                              onSessionModeChanged: onSessionModeChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final viewportHeight = (constraints.maxWidth * 0.9).clamp(
                  320.0,
                  520.0,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: viewportHeight,
                        child: Panel(
                          title: 'Viewport',
                          child: viewportContent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Panel(
                        title: 'Connection',
                        expandChild: false,
                        child: _controls(
                          context,
                          homeState,
                          hlsControls,
                          scrollable: false,
                          initialConnectionUrl: initialConnectionUrl,
                          onRoleChanged: onRoleChanged,
                          onSessionModeChanged: onSessionModeChanged,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}
