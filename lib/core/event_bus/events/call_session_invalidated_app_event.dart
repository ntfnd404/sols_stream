import 'package:sols_stream/core/event_bus/app_event.dart';
import 'package:sols_stream/core/event_bus/events/call_session_invalidation_reason.dart';

export 'package:sols_stream/core/event_bus/events/call_session_invalidation_reason.dart';

/// Announces that presentation state made the active call session obsolete.
final class CallSessionInvalidatedAppEvent extends AppEvent {
  final CallSessionInvalidationReason reason;

  const CallSessionInvalidatedAppEvent(this.reason);
}
