from pathlib import Path

p = Path('lib/screens/settings_screen.dart')
s = p.read_text()
s = s.replace("import '../core/formatters.dart';\n", '')
s = s.replace("\n  static String? _requiredValidator(String? value) =>\n      value == null || value.trim().isEmpty ? 'Bu alan boş bırakılamaz.' : null;\n", '\n')
s = s.replace('    this.color = MizanTheme.blue,\n', '')
s = s.replace('  final Color color;\n', '')
s = s.replace('color.withValues(alpha: .06)', 'MizanTheme.blue.withValues(alpha: .06)')
s = s.replace('color.withValues(alpha: .22)', 'MizanTheme.blue.withValues(alpha: .22)')
s = s.replace('Icon(icon, color: color)', 'Icon(icon, color: MizanTheme.blue)')
p.write_text(s)

p = Path('test/manual_overdue_edit_confirmation_test.dart')
s = p.read_text()
old = """    expect(
      find.textContaining(
        'bildirim, rapor ve ödeme hesaplarını yeniden hesaplayacaktır',
      ),
      findsOneWidget,
    );
"""
new = """    expect(find.textContaining('bildirim'), findsNothing);
"""
if old not in s:
    raise SystemExit('manual overdue stale expectation block not found')
p.write_text(s.replace(old, new))

p = Path('test/ui_interaction_test.dart')
s = p.read_text().replace('Faturalar', 'Fatura')
old_block = """    expect(find.text('Bildirim sistemi'), findsOneWidget);
    expect(find.text('Otomatik senkronizasyon'), findsOneWidget);
    final notificationSlots = find.textContaining('özel bildirim saati');
    await tester.scrollUntilVisible(
      notificationSlots,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(notificationSlots, findsOneWidget);
    expect(find.text('Ses ve titreşim'), findsOneWidget);
"""
new_block = """    expect(find.text('Bildirim sistemi'), findsNothing);
    expect(find.text('Otomatik senkronizasyon'), findsNothing);
    expect(find.textContaining('özel bildirim saati'), findsNothing);
    expect(find.text('Ses ve titreşim'), findsNothing);
"""
if old_block not in s:
    raise SystemExit('settings notification block not found')
s = s.replace(old_block, new_block)
start_marker = "  testWidgets('Bildirim ayarları özet ve ayrıntı olarak açık biçimde ayrılır'"
start = s.index(start_marker)
end = s.index("\n  });\n}", start) + len("\n  });")
replacement = """  testWidgets('shipping ayarlarında bildirim sistemi tamamen yoktur', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.settings_outlined);

    for (final removedCopy in const [
      'Bildirim sistemi',
      'Bildirim izni',
      'Dakik bildirim izni',
      'Planlanan bildirim',
      'Otomatik senkronizasyon',
      'Bildirimleri yeniden planla',
      'Bildirim izinlerini aç',
      'Dakik bildirim iznini aç',
      'Ödeme hatırlatması 1',
      'Hatırlatmayı düzenle',
      '1 dakika sonra test bildirimi',
      'Ses ve titreşim',
    ]) {
      expect(find.text(removedCopy), findsNothing, reason: removedCopy);
    }
    expect(find.text('Anlık yerel kayıt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });"""
p.write_text(s[:start] + replacement + s[end:])

p = Path('test/responsive_test.dart')
s = p.read_text()
start_marker = "  testWidgets('320x568 bildirim ayrıntısı taşmasız açılır'"
start = s.index(start_marker)
end = s.index("\n  });\n}", start) + len("\n  });")
replacement = """  testWidgets('320x568 bildirimsiz ayarlar taşmasız açılır', (tester) async {
    await _pumpAt(tester, const Size(320, 568));
    final bar = find.byType(NavigationBar);
    final rail = find.byType(NavigationRail);
    final root = bar.evaluate().isNotEmpty ? bar : rail;
    await tester.tap(
      find.descendant(of: root, matching: find.byIcon(Icons.settings_outlined)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bildirim sistemi'), findsNothing);
    expect(find.text('Ödeme hatırlatması 1'), findsNothing);
    expect(find.text('Hatırlatmayı düzenle'), findsNothing);
    expect(find.text('Anlık yerel kayıt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });"""
p.write_text(s[:start] + replacement + s[end:])
