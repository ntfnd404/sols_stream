import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/feature/call/bloc/call_bloc.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/view/home_view.dart';

import '../../../helpers/fake_app_dependencies.dart';
import '../../call/bloc/fakes/fake_realtime_media_session.dart';

void main() {
  testWidgets('narrow layout scrolls from viewport to connection controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = fakeAppDependencies(ownEventBus: false);
    final homeBloc = HomeBloc(eventBus: dependencies.eventBus);
    final callBloc = CallBloc(
      peerSignaling: dependencies.peerSignaling,
      mediaSession: FakeRealtimeMediaSession(),
      eventBus: dependencies.eventBus,
    );
    await tester.pumpWidget(
      AppScope(
        dependencies: dependencies,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: homeBloc),
            BlocProvider.value(value: callBloc),
          ],
          child: MaterialApp(
            home: HomeView(
              onRoleChanged: (_) {},
              onSessionModeChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Viewport'), findsOneWidget);
    expect(find.text('Connection'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('Wallet'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Wallet'), findsOneWidget);
    expect(
      tester.getBottomRight(find.textContaining('Wallet')).dy,
      lessThanOrEqualTo(700),
    );
  });
}
