import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/idl/idl_file_synchronizer.dart';

void main() {
  late Directory directory;
  late File output;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('signaling_idl_');
    output = File('${directory.path}/sols_stream.json');
  });

  tearDown(() => directory.delete(recursive: true));

  test('writes a missing IDL in update mode', () async {
    final result = await synchronizeIdlFile(
      output: output,
      idl: {'instructions': <Object>[]},
      checkOnly: false,
    );

    expect(result, IdlSyncResult.written);
    expect(await output.exists(), isTrue);
    expect(
      directory.listSync().whereType<File>().map((file) => file.path),
      [output.path],
    );
  });

  test('treats differently ordered JSON as unchanged', () async {
    await output.writeAsString('{"b":2,"a":1}');

    final result = await synchronizeIdlFile(
      output: output,
      idl: {'a': 1, 'b': 2},
      checkOnly: true,
    );

    expect(result, IdlSyncResult.unchanged);
  });

  test('atomically replaces an outdated IDL in update mode', () async {
    await output.writeAsString('{"version":1}');

    final result = await synchronizeIdlFile(
      output: output,
      idl: {'version': 2},
      checkOnly: false,
    );

    expect(result, IdlSyncResult.written);
    expect(await output.readAsString(), '{\n  "version": 2\n}\n');
    expect(
      directory.listSync().whereType<File>().map((file) => file.path),
      [output.path],
    );
  });

  test('check-only reports drift without modifying the file', () async {
    await output.writeAsString('{"version":1}');
    final before = await output.readAsString();

    final result = await synchronizeIdlFile(
      output: output,
      idl: {'version': 2},
      checkOnly: true,
    );

    expect(result, IdlSyncResult.outOfDate);
    expect(await output.readAsString(), before);
  });
}
