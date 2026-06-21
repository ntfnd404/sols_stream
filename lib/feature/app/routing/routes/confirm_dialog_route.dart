part of 'app_route.dart';

/// Confirmation dialog rendered as a URL-addressable route via [TransparentPage]:
/// back / barrier dismiss closes it (null), the buttons return a bool via
/// `popWith`. [message] is a typed field carried in the URL.
final class ConfirmDialogRoute extends AppRoute {
  final String message;

  @override
  LocalKey get pageKey => ValueKey<String>('confirm:$message');

  @override
  String get name => 'confirm';

  const ConfirmDialogRoute(this.message);

  @override
  Map<String, String> toParams() => <String, String>{'message': message};

  @override
  Page<Object?> buildPage(BuildContext context) => TransparentPage<bool>(
    key: pageKey,
    child: ConfirmDialog(
      message: message,
      onConfirm: () => context.navigator.popWith<bool>(true),
      onCancel: () => context.navigator.popWith<bool>(false),
    ),
  );
}
