import 'package:sols_stream/feature/home/model/session_mode.dart';
import 'package:sols_stream/feature/home/model/web_rtc_role.dart';

final class HomeLaunchConfig {
  final SessionMode sessionMode;
  final WebRtcRole webRtcRole;

  const HomeLaunchConfig({
    required this.sessionMode,
    required this.webRtcRole,
  });
}
