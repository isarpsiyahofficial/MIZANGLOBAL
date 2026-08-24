import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup exposes core app before monetization initialization', () {
    final source = File('lib/main.dart').readAsStringSync();
    final controllerPublished = source.indexOf('_controller = controller;');
    final monetizationStarted = source.indexOf(
      'unawaited(_initializeMonetization(candidateMonetization));',
    );

    expect(controllerPublished, greaterThanOrEqualTo(0));
    expect(monetizationStarted, greaterThan(controllerPublished));

    final setupGate = source.indexOf(
      'if (!widget.controller.state.setupCompleted)',
    );
    final legalGate = source.indexOf('if (_legalAccepted == false)');
    final offlineGate = source.indexOf(
      'FreeOfflineGate(controller: monetization)',
    );

    expect(setupGate, greaterThanOrEqualTo(0));
    expect(legalGate, greaterThan(setupGate));
    expect(offlineGate, greaterThan(legalGate));
  });

  test(
    'personal and corporate debt report reference keeps record currency',
    () {
      final source = File('lib/services/report_service.dart').readAsStringSync();
      final personalLoop = source.lastIndexOf(
        'for (final debt in person.personalDebts)',
      );
      expect(personalLoop, greaterThanOrEqualTo(0));

      final personalBlockEnd = source.indexOf(
        'for (final bill in person.bills)',
        personalLoop,
      );
      expect(personalBlockEnd, greaterThan(personalLoop));

      final personalBlock = source.substring(personalLoop, personalBlockEnd);
      expect(personalBlock, contains('currencyCode: debt.currencyCode'));
    },
  );

  test('wide navigation labels use selected application language', () {
    final source = File(
      'lib/widgets/responsive_scaffold.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('label: Text(destination.label)')));
    expect(
      source,
      contains('label: Text(MizanI18n.text(destination.label))'),
    );
  });
}
