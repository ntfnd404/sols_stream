import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';
import 'package:sols_stream/core/event_bus/events/call_session_invalidated_app_event.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/transport_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';

void main() {
  group('HomeBloc', () {
    group('WebRtcRoleChangedEvent', () {
      blocTest<HomeBloc, HomeState>(
        'emits new role when role differs from current',
        build: _makeBloc,
        act: (bloc) => bloc.add(const WebRtcRoleChangedEvent(WebRtcRole.viewer)),
        expect: () => [
          const HomeState(webRtcRole: WebRtcRole.viewer),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits nothing when same role is set again',
        build: _makeBloc,
        act: (bloc) => bloc.add(const WebRtcRoleChangedEvent(WebRtcRole.publisher)),
        expect: () => <HomeState>[],
      );

      test('emits CallSessionInvalidatedAppEvent before state changes', () async {
        final eventBus = AppEventBus();
        final bloc = HomeBloc(eventBus: eventBus);
        final events = <CallSessionInvalidatedAppEvent>[];
        final sub = eventBus.on<CallSessionInvalidatedAppEvent>().listen(events.add);

        bloc.add(const WebRtcRoleChangedEvent(WebRtcRole.viewer));
        await Future<void>.delayed(Duration.zero);

        expect(events, [isA<CallSessionInvalidatedAppEvent>()]);
        expect(events.first.reason, CallSessionInvalidationReason.roleChanged);
        expect(bloc.state.webRtcRole, WebRtcRole.viewer);

        await sub.cancel();
        await bloc.close();
        await eventBus.dispose();
      });

      test('does not emit CallSessionInvalidatedAppEvent when role is unchanged', () async {
        final eventBus = AppEventBus();
        final bloc = HomeBloc(eventBus: eventBus);
        final events = <CallSessionInvalidatedAppEvent>[];
        final sub = eventBus.on<CallSessionInvalidatedAppEvent>().listen(events.add);

        bloc.add(const WebRtcRoleChangedEvent(WebRtcRole.publisher));
        await Future<void>.delayed(Duration.zero);

        expect(events, isEmpty);

        await sub.cancel();
        await bloc.close();
        await eventBus.dispose();
      });
    });

    group('TransportModeChangedEvent', () {
      blocTest<HomeBloc, HomeState>(
        'emits new transport mode when it differs',
        build: _makeBloc,
        act: (bloc) => bloc.add(const TransportModeChangedEvent(TransportMode.hls)),
        expect: () => [const HomeState(transportMode: TransportMode.hls)],
      );

      blocTest<HomeBloc, HomeState>(
        'emits nothing when same transport mode is set again',
        build: _makeBloc,
        act: (bloc) => bloc.add(const TransportModeChangedEvent(TransportMode.webrtc)),
        expect: () => <HomeState>[],
      );

      test('emits TransportModeChangingAction before state changes', () async {
        final bloc = _makeBloc();
        final actions = <HomeAction>[];
        final sub = bloc.actionStream.listen(actions.add);

        bloc.add(const TransportModeChangedEvent(TransportMode.hls));
        await Future<void>.delayed(Duration.zero);

        expect(actions, [isA<TransportModeChangingAction>()]);

        await sub.cancel();
        await bloc.close();
      });

      test('emits CallSessionInvalidatedAppEvent when switching away from WebRTC', () async {
        final eventBus = AppEventBus();
        final bloc = HomeBloc(eventBus: eventBus);
        final events = <CallSessionInvalidatedAppEvent>[];
        final sub = eventBus.on<CallSessionInvalidatedAppEvent>().listen(events.add);

        bloc.add(const TransportModeChangedEvent(TransportMode.hls));
        await Future<void>.delayed(Duration.zero);

        expect(events, [isA<CallSessionInvalidatedAppEvent>()]);
        expect(events.first.reason, CallSessionInvalidationReason.transportChanged);

        await sub.cancel();
        await bloc.close();
        await eventBus.dispose();
      });
    });

    group('SessionModeChangedEvent', () {
      blocTest<HomeBloc, HomeState>(
        'emits the independent session mode',
        build: _makeBloc,
        act: (bloc) => bloc.add(
          const SessionModeChangedEvent(SessionMode.stream),
        ),
        expect: () => [
          const HomeState(sessionMode: SessionMode.stream),
        ],
      );
    });

    group('HomeScope', () {
      test('initial role is publisher for stream intent', () {
        final bloc = _makeBloc();
        expect(bloc.state.webRtcRole, WebRtcRole.publisher);
        bloc.close();
      });

      test('initial role can be set to viewer', () {
        final bloc = _makeBloc(initialRole: WebRtcRole.viewer);
        expect(bloc.state.webRtcRole, WebRtcRole.viewer);
        bloc.close();
      });
    });
  });
}

HomeBloc _makeBloc({WebRtcRole initialRole = WebRtcRole.publisher}) => HomeBloc(
  eventBus: AppEventBus(),
  initialRole: initialRole,
);
