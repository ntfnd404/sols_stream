part of 'app_route.dart';

/// Full-screen network picker pushed for a result (`pushForResult`/`popWith`).
final class NetworkPickerRoute extends AppRoute {
  @override
  LocalKey get pageKey => const ValueKey<String>('network-picker');

  @override
  String get name => 'network-picker';

  const NetworkPickerRoute();

  @override
  Map<String, String> toParams() => const <String, String>{};

  @override
  Page<Object?> buildPage(BuildContext context) => MaterialPage<void>(key: pageKey, child: const NetworkPickerScreen());
}
