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

String _normalizedPath(File file) => file.path
    .replaceAll('\\', '/')
    .replaceFirst(RegExp(r'^\./'), '');

bool _isAuditedTextPath(String path) {
  if (_excludedPathPrefixes.any(path.startsWith)) return false;
  if (path == '.gitignore' || path == '.metadata') return true;
  return _textExtensions.any(path.endsWith);
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

    for (final entity in Directory('.').listSync(
      recursive: true,
      followLinks: false,
    )) {
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
      for (final entity in root.listSync(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final path = _normalizedPath(entity);
        if (!const ['.dart', '.kt', '.kts', '.java'].any(path.endsWith)) {
          continue;
        }
        final lines = entity.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          final trimmed = lines[index].trimLeft();
          if (!trimmed.startsWith('//')) continue;
          final allowedDirective =
              trimmed == '// dart format off' ||
              trimmed == '// dart format on' ||
              trimmed.startsWith('// ignore:') ||
              trimmed.startsWith('// ignore_for_file:');
          if (!allowedDirective) {
            violations.add('$path:${index + 1}: ${lines[index].trim()}');
          }
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
