import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shipping source contains no assistant or model fingerprints', () {
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
    final roots = <Directory>[
      Directory('lib'),
      Directory('android/app/src/main'),
      Directory('tools'),
      Directory('.github/workflows'),
    ];
    final allowedExtensions = <String>{
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
    };
    final violations = <String>[];

    for (final root in roots.where((item) => item.existsSync())) {
      for (final entity in root.listSync(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final path = entity.path.replaceAll('\\', '/');
        if (!allowedExtensions.any(path.endsWith)) continue;
        final lower = entity.readAsStringSync().toLowerCase();
        for (final marker in forbidden) {
          if (lower.contains(marker)) {
            violations.add('$path => $marker');
          }
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('production Dart has no explanatory line comments', () {
    final violations = <String>[];
    final root = Directory('lib');
    if (!root.existsSync()) return;

    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
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
          violations.add('${entity.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
