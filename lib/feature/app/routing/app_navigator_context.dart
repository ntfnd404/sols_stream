import 'package:flutter/widgets.dart';

import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/app/routing/app_navigator.dart';

/// Reads the [AppNavigator] from the widget tree (see `NavigatorScope`, C5).
extension AppNavigatorContext on BuildContext {
  AppNavigator get navigator => NavigatorScope.of<AppNavigator>(this);
}
