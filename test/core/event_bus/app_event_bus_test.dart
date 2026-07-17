import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/event_bus/app_event.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';

void main() {
  test('dispose waits until the broadcast controller closes', () async {
    final eventBus = AppEventBus();
    var streamDone = false;
    final subscription = eventBus.on<AppEvent>().listen(
      (_) {},
      onDone: () => streamDone = true,
    );

    await eventBus.dispose();

    expect(streamDone, isTrue);
    await subscription.cancel();
  });
}
