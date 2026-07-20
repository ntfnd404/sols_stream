import 'dart:io';

import 'dart_define_file_validator.dart';

const int _usageExitCode = 64;
const int _invalidDataExitCode = 65;

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/quality/validate_dart_defines.dart <env-file>',
    );
    exitCode = _usageExitCode;

    return;
  }

  try {
    final contents = File(arguments.single).readAsStringSync();
    const DartDefineFileValidator().validate(contents);
    stdout.writeln('Dart define configuration is valid.');
  } on FileSystemException {
    stderr.writeln('Unable to read dart-define configuration file.');
    exitCode = _invalidDataExitCode;
  } on DartDefineValidationException catch (error) {
    stderr.writeln(error.message);
    exitCode = _invalidDataExitCode;
  }
}
