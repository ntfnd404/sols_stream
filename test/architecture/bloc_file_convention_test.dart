import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature BLoCs use aggregate files and structurally immutable State snapshots', () {
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
      _expectStructurallyImmutableStates(filesByName['${featureName}_state.dart']!);
      if (filesByName['${featureName}_action.dart'] case final actionFile?) {
        _expectClassSuffix(actionFile, 'Action');
      }
    }
  });

  test('application events are structurally immutable snapshots', () {
    final eventClasses = _dartFiles('lib')
        .expand(
          (file) => parseString(content: file.readAsStringSync(), path: file.path).unit.declarations,
        )
        .whereType<ClassDeclaration>()
        .where((declaration) => declaration.extendsClause?.superclass.toSource() == 'AppEvent');

    expect(eventClasses, isNotEmpty);
    for (final eventClass in eventClasses) {
      expect(
        _structuralImmutabilityViolations(eventClass),
        isEmpty,
        reason: '${eventClass.namePart.typeName.lexeme} must be a structurally immutable event snapshot.',
      );
    }
  });

  test('structural snapshot guard rejects mutable fields and value collections', () {
    final unit = parseString(
      content: '''
class MutableState {
  int counter = 0;
  final List<int> values = const [];
  final Uint8List bytes;
  final Int32x4List vectors;

  MutableState(this.bytes, this.vectors);
}
''',
    ).unit;
    final state = unit.declarations.whereType<ClassDeclaration>().single;

    expect(
      _structuralImmutabilityViolations(state),
      containsAll([
        'class must be final',
        'counter must be final',
        'values exposes mutable List<int>',
        'bytes exposes mutable Uint8List',
        'vectors exposes mutable Int32x4List',
      ]),
    );
  });
}

void _expectStructurallyImmutableStates(File file) {
  final unit = parseString(content: file.readAsStringSync(), path: file.path).unit;
  final states = unit.declarations.whereType<ClassDeclaration>().where(
    (declaration) => declaration.namePart.typeName.lexeme.endsWith('State'),
  );

  for (final state in states) {
    expect(
      _structuralImmutabilityViolations(state),
      isEmpty,
      reason: '${state.namePart.typeName.lexeme} must be a structurally immutable State snapshot.',
    );
  }
}

List<String> _structuralImmutabilityViolations(ClassDeclaration declaration) {
  final violations = <String>[];
  if (declaration.finalKeyword == null) violations.add('class must be final');

  for (final field in declaration.body.members.whereType<FieldDeclaration>().where((field) => !field.isStatic)) {
    for (final variable in field.fields.variables) {
      if (!field.fields.isFinal) violations.add('${variable.name.lexeme} must be final');
      final type = field.fields.type?.toSource();
      if (type != null && _mutableValueCollection.hasMatch(type)) {
        violations.add('${variable.name.lexeme} exposes mutable $type');
      }
    }
  }

  return violations;
}

final _mutableValueCollection = RegExp(
  r'^(?:List|Map|Set|Queue|HashMap|LinkedHashMap|SplayTreeMap|HashSet|LinkedHashSet|SplayTreeSet|ByteData|ByteBuffer|Uint\d+(?:Clamped)?List|Int\d+(?:x\d+)?List|Float\d+(?:x\d+)?List)\b',
);

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

Iterable<File> _dartFiles(String root) =>
    Directory(root).listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart'));
