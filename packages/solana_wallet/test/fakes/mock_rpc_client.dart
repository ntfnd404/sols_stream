import 'package:mocktail/mocktail.dart';
import 'package:solana/dto.dart' show BalanceResult;
import 'package:solana/solana.dart' show RpcClient;

class MockRpcClient extends Mock implements RpcClient {}

class MockBalanceResult extends Mock implements BalanceResult {}
