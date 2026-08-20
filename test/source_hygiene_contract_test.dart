import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _textExtensions = <String>{
  '.dart',
  '.kt',
  '.kts',
  '.java',
  '.xml',
  '.py',
  '.yaml',
  '.yml',
  '.json',
  '.md',
  '.txt',
  '.properties',
  '.gradle',
  '.lock',
};

const _productionExtensions = <String>{'.dart', '.kt', '.kts', '.java'};

const _excludedPathPrefixes = <String>[
  '.git/',
  '.dart_tool/',
  '.idea/',
  'build/',
  'coverage/',
  'test/failures/',
  'test/output/',
  'android/.gradle/',
];

String _normalizedPath(File file) {
  final normalized = file.path.replaceAll('\\', '/');
  return normalized.replaceFirst(RegExp(r'^\./'), '');
}

bool _isAuditedTextPath(String path) {
  if (_excludedPathPrefixes.any(path.startsWith)) return false;
  if (path == '.gitignore' || path == '.metadata') return true;
  return _textExtensions.any(path.endsWith);
}

bool _isAllowedDirective(String line) {
  if (line == '// dart format off') return true;
  if (line == '// dart format on') return true;
  if (line.startsWith('// ignore:')) return true;
  return line.startsWith('// ignore_for_file:');
}

void main() {
  test('repository text contains no forbidden provenance markers', () {
    final forbidden = <String>[
      '${'chat'}${'gpt'}',
      '${'open'}${'ai'}',
      '${'co'}${'pilot'}',
      '${'cla'}${'ude'}',
      '${'anthro'}${'pic'}',
      '${'gem'}${'ini'}',
      '${'language'} ${'model'}',
      '${'ai'}-${'generated'}',
      '${'generated'} ${'by'} ${'ai'}',
    ];
    final violations = <String>[];
    final entities = Directory(
      '.',
    ).listSync(recursive: true, followLinks: false);

    for (final entity in entities) {
      if (entity is! File) continue;
      final path = _normalizedPath(entity);
      if (!_isAuditedTextPath(path)) continue;
      final lower = entity.readAsStringSync().toLowerCase();
      for (final marker in forbidden) {
        if (lower.contains(marker)) {
          violations.add('$path => $marker');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('production source has no explanatory line comments', () {
    final violations = <String>[];
    final roots = <Directory>[
      Directory('lib'),
      Directory('android/app/src/main'),
    ];

    for (final root in roots.where((item) => item.existsSync())) {
      final entities = root.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is! File) continue;
        final path = _normalizedPath(entity);
        if (!_productionExtensions.any(path.endsWith)) continue;
        final lines = entity.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          final trimmed = lines[index].trimLeft();
          if (!trimmed.startsWith('//')) continue;
          if (!_isAllowedDirective(trimmed)) {
            violations.add('$path:${index + 1}: ${lines[index].trim()}');
          }
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('shipping workflows are read-only and non-self-modifying', () {
    final workflowRoot = Directory('.github/workflows');
    expect(workflowRoot.existsSync(), isTrue);
    expect(
      File('.github/workflows/validate-project-final-fix.yml').existsSync(),
      isFalse,
    );

    final forbidden = <String>[
      'contents: write',
      'git commit',
      'git push',
    ];
    final violations = <String>[];
    for (final entity in workflowRoot.listSync(followLinks: false)) {
      if (entity is! File) continue;
      final path = _normalizedPath(entity);
      if (!path.endsWith('.yml') && !path.endsWith('.yaml')) continue;
      final text = entity.readAsStringSync().toLowerCase();
      for (final marker in forbidden) {
        if (text.contains(marker)) {
          violations.add('$path => $marker');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
