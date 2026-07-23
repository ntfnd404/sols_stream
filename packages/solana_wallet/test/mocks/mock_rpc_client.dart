import 'package:mocktail/mocktail.dart';
import 'package:solana/solana.dart' show RpcClient;

final class MockRpcClient extends Mock implements RpcClient {}
