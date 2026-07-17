import 'package:ephemeral_bloc/ephemeral_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';
import 'package:sols_stream/core/event_bus/events/call_session_invalidated_app_event.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';

part 'home_action.dart';
part 'home_event.dart';
part 'home_state.dart';

final class HomeBloc extends Bloc<HomeEvent, HomeState> with EphemeralBlocMixin<HomeState, HomeAction> {
  final AppEventBus _eventBus;

  HomeBloc({
    required this._eventBus,
    WebRtcRole initialRole = WebRtcRole.publisher,
    SessionMode initialSessionMode = SessionMode.p2p,
  }) : super(
         HomeState(
           webRtcRole: initialRole,
           sessionMode: initialSessionMode,
         ),
       ) {
    on<TransportModeChangedEvent>(_onTransportModeChanged);
    on<WebRtcRoleChangedEvent>(_onWebRtcRoleChanged);
    on<SessionModeChangedEvent>(_onSessionModeChanged);
  }

  void _onTransportModeChanged(
    TransportModeChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    if (event.mode == state.transportMode) return;
    if (event.mode != TransportMode.webrtc) {
      _eventBus.emit(
        const CallSessionInvalidatedAppEvent(
          CallSessionInvalidationReason.transportChanged,
        ),
      );
    }
    emitAction(TransportModeChangingAction(event.mode));
    emit(state.copyWith(transportMode: event.mode));
  }

  void _onWebRtcRoleChanged(
    WebRtcRoleChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    if (event.role == state.webRtcRole) return;
    _eventBus.emit(
      const CallSessionInvalidatedAppEvent(
        CallSessionInvalidationReason.roleChanged,
      ),
    );
    emit(state.copyWith(webRtcRole: event.role));
  }

  void _onSessionModeChanged(
    SessionModeChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    if (event.mode == state.sessionMode) return;
    _eventBus.emit(
      const CallSessionInvalidatedAppEvent(
        CallSessionInvalidationReason.transportChanged,
      ),
    );
    emit(state.copyWith(sessionMode: event.mode));
  }
}
