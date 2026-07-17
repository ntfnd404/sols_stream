import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature BLoCs use one aggregate file per BLoC type', () {
    final blocDirectories = Directory(
      'lib/feature',
    ).listSync(recursive: true).whereType<Directory>().where((directory) => directory.path.endsWith('/bloc'));

    for (final directory in blocDirectories) {
      final featureName = directory.parent.path.split(Platform.pathSeparator).last;
      final dartFiles = directory.listSync().whereType<File>().where((file) => file.path.endsWith('.dart')).toList();
      final filesByName = {
        for (final file in dartFiles) file.uri.pathSegments.last: file,
      };
      final requiredFiles = {
        '${featureName}_bloc.dart': 'Bloc',
        '${featureName}_event.dart': 'Event',
        '${featureName}_state.dart': 'State',
      };
      final allowedFiles = {
        ...requiredFiles.keys,
        '${featureName}_action.dart',
      };

      expect(
        filesByName.keys,
        containsAll(requiredFiles.keys),
        reason: '${directory.path} must contain the classic BLoC aggregate files.',
      );
      expect(
        filesByName.keys.where((name) => !allowedFiles.contains(name)),
        isEmpty,
        reason: '${directory.path} must group BLoC types by aggregate file.',
      );

      for (final entry in requiredFiles.entries) {
        _expectClassSuffix(filesByName[entry.key]!, entry.value);
      }
      if (filesByName['${featureName}_action.dart'] case final actionFile?) {
        _expectClassSuffix(actionFile, 'Action');
      }
    }
  });
}

void _expectClassSuffix(File file, String suffix) {
  final unit = parseString(
    content: file.readAsStringSync(),
    path: file.path,
  ).unit;
  final classNames = unit.declarations
      .whereType<ClassDeclaration>()
      .map((declaration) => declaration.namePart.typeName.lexeme)
      .toList();

  expect(
    classNames,
    isNotEmpty,
    reason: '${file.path} must declare at least one $suffix class.',
  );
  expect(
    classNames.where((name) => !name.endsWith(suffix)),
    isEmpty,
    reason: 'Every class in ${file.path} must end with $suffix.',
  );
}
