import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/account/view/account_shell.dart';
import 'package:sols_stream/feature/account/view/account_tab.dart';
import 'package:sols_stream/feature/account/view/network_picker_screen.dart';
import 'package:sols_stream/feature/account/view/settings_detail_screen.dart';
import 'package:sols_stream/feature/account/view/settings_screen.dart';
import 'package:sols_stream/feature/app/lock/unlock_screen.dart';
import 'package:sols_stream/feature/app/routing/app_navigator.dart';
import 'package:sols_stream/feature/app/view/confirm_dialog.dart';
import 'package:sols_stream/feature/app/view/not_found_screen.dart';
import 'package:sols_stream/feature/home/view/enums/home_intent.dart';
import 'package:sols_stream/feature/home/view/home_screen.dart';
import 'package:sols_stream/feature/hub/view/hub_screen.dart';

part 'hub_route.dart';
part 'home_route.dart';
part 'account_route.dart';
part 'settings_home_route.dart';
part 'settings_detail_route.dart';
part 'network_picker_route.dart';
part 'confirm_dialog_route.dart';
part 'lock_route.dart';
part 'not_found_route.dart';

/// Base for every route in this app.
///
/// Typed fields at the API/screen surface; the `Map` only appears inside each
/// route's [toParams] and the registry decoder (the URL wire format). Value
/// equality and [hashCode] derive from [pageKey] + runtimeType, so a leaf route
/// only needs a distinct [pageKey] to be a distinct page. Shells (with children
/// or extra identity) override equality.
sealed class AppRoute implements RouteNode {
  @override
  List<AppRoute> get children => const <AppRoute>[];

  @override
  int get hashCode => Object.hash(runtimeType, pageKey);

  const AppRoute();

  @override
  AppRoute withChildren(List<RouteNode> children) => this;

  @override
  bool operator ==(Object other) => other is AppRoute && other.runtimeType == runtimeType && other.pageKey == pageKey;
}
