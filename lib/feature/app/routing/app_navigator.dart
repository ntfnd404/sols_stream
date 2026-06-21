import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/account/view/account_tab.dart';
import 'package:sols_stream/feature/app/routing/routes/app_route.dart';
import 'package:sols_stream/feature/home/view/enums/home_intent.dart';

export 'app_navigator_context.dart';

/// Typed navigation sugar for the app. Screens call these instead of building
/// route objects, and a later engine swap only re-implements this class.
class AppNavigator extends NavigationController<AppRoute> {
  const AppNavigator(super.state);

  void toHub() => clearAndPush(const HubRoute());

  void toHome(HomeIntent intent) => pushOrReplaceTop(HomeRoute(intent));

  void toAccount() => push(const AccountRoute());

  void selectAccountTab(AccountTab tab) => mutateAt(
    const <String>['account'],
    (node) => switch (node) {
      AccountRoute(:final stack) => AccountRoute(activeTab: tab, stack: stack),
      _ => node,
    },
  );

  Future<String?> pickNetwork() => pushForResult<String>(const NetworkPickerRoute());

  Future<bool?> confirm(String message) => pushForResult<bool>(ConfirmDialogRoute(message));

  void openSettingsDetail(int id) => mutateAt(
    const <String>['account'],
    (node) => switch (node) {
      AccountRoute(:final stack) => AccountRoute(
        activeTab: AccountTab.settings,
        stack: <AppRoute>[...stack, SettingsDetailRoute(id)],
      ),
      _ => node,
    },
  );
}
