import 'package:flutter/foundation.dart';
import 'package:sols_stream/core/config/rpc_environment.dart';

@immutable
final class AppEnvironment {
  final RpcEnvironment rpc;

  const AppEnvironment({required this.rpc});
}
