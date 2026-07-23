import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';
import 'package:sols_stream/feature/home/bloc/home_bloc.dart';
import 'package:sols_stream/feature/home/view/widgets/hls_section.dart';

void main() {
  testWidgets('shows empty URL status without leaving the widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(eventBus: AppEventBus()),
          child: HlsSection(
            builder: (context, viewport, controls) => Scaffold(
              body: Column(
                children: [
                  controls,
                  Expanded(child: viewport),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Play'));
    await tester.pump();

    expect(find.text('Stream URL is empty.'), findsOneWidget);
  });
}
