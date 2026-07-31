import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/services/local_store.dart';

import 'test_support.dart';

void main() {
  test('ilk açılış boş durum oluşturur ve örnek kayıt yazmaz', () async {
    final directory = await Directory.systemTemp.createTemp('mizan-empty-test');
    addTearDown(() => directory.delete(recursive: true));
    final store = LocalStore(directory: directory);

    final loaded = await store.load();

    expect(loaded.source, StoreLoadSource.fresh);
    expect(loaded.state.people, isEmpty);
    expect(loaded.state.expenses, isEmpty);
    expect(loaded.state.setupCompleted, isFalse);
    expect(paymentCount(loaded.state), 0);
  });

  test('atomik kayıt ve bozuk ana dosyada yedek kurtarma çalışır', () async {
    final directory = await Directory.systemTemp.createTemp('mizan-store-test');
    addTearDown(() => directory.delete(recursive: true));
    final store = LocalStore(directory: directory);
    final first = comprehensiveState();
    await store.save(first);
    final second = first.copyWith(notificationsEnabled: false);
    await store.save(second);

    final loaded = await store.load();
    expect(loaded.state.notificationsEnabled, isFalse);

    await File('${directory.path}/mizan_state.json').writeAsString('{bozuk');
    final recovered = await store.load();
    expect(recovered.source, StoreLoadSource.backup);
    expect(recovered.state.notificationsEnabled, isTrue);
    expect(recovered.state.people.single.personalDebts, hasLength(1));
  });

  test('ana ve yedek dosya bozuksa mevcut dosyalar silinmez', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mizan-corrupt-test',
    );
    addTearDown(() => directory.delete(recursive: true));
    final primary = File('${directory.path}/mizan_state.json');
    final backup = File('${directory.path}/mizan_state.backup.json');
    await primary.writeAsString('bozuk-ana');
    await backup.writeAsString('bozuk-yedek');
    final store = LocalStore(directory: directory);

    await expectLater(store.load(), throwsA(isA<FileSystemException>()));
    expect(await primary.readAsString(), 'bozuk-ana');
    expect(await backup.readAsString(), 'bozuk-yedek');
  });
}
