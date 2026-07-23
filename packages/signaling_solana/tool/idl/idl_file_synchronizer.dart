import 'dart:convert';
import 'dart:io';

import 'idl_sync_result.dart';

export 'idl_sync_result.dart';

/// Compares canonical JSON and optionally updates the versioned IDL file.
Future<IdlSyncResult> synchronizeIdlFile({
  required File output,
  required Map<String, dynamic> idl,
  required bool checkOnly,
}) async {
  final existing = await _readJsonObject(output);
  if (existing != null && _canonicalJson(existing) == _canonicalJson(idl)) {
    return IdlSyncResult.unchanged;
  }
  if (checkOnly) return IdlSyncResult.outOfDate;

  await output.parent.create(recursive: true);
  final temporary = File('${output.path}.tmp.$pid');
  try {
    await temporary.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(idl)}\n',
      flush: true,
    );
    await temporary.rename(output.path);
  } finally {
    if (await temporary.exists()) {
      await temporary.delete();
    }
  }

  return IdlSyncResult.written;
}

Future<Map<String, dynamic>?> _readJsonObject(File file) async {
  if (!await file.exists()) return null;
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map<String, dynamic>) {
    throw FormatException(
      'Existing IDL JSON root is not an object: ${file.path}',
    );
  }

  return decoded;
}

String _canonicalJson(Object? value) => jsonEncode(_sortJson(value));

Object? _sortJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();

    return {
      for (final key in keys) key: _sortJson(value[key]),
    };
  }
  if (value is List) return value.map(_sortJson).toList();

  return value;
}
