part of 'call_bloc.dart';

sealed class CallAction {
  const CallAction();
}

final class ShowStatusMessageAction extends CallAction {
  final String message;

  const ShowStatusMessageAction(this.message);
}
