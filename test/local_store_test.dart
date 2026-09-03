import 'dart:convert';
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
    final second = first.copyWith(appLanguageTag: 'en');
    await store.save(second);

    final loaded = await store.load();
    expect(loaded.state.appLanguageTag, 'en');

    await File('${directory.path}/mizan_state.json').writeAsString('{bozuk');
    final recovered = await store.load();
    expect(recovered.source, StoreLoadSource.backup);
    expect(recovered.state.appLanguageTag, 'tr');
    expect(recovered.state.people.single.personalDebts, hasLength(1));
  });

  test(
    'doğrulanmış geçici kayıt kesinti sonrası son durumu kurtarır',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'mizan-interrupted-store-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = LocalStore(directory: directory);
      final first = comprehensiveState();
      await store.save(first);
      final second = first.copyWith(appLanguageTag: 'en');
      await store.save(second);

      final primary = File('${directory.path}/mizan_state.json');
      final temporary = File('${directory.path}/mizan_state.tmp.json');
      await primary.copy(temporary.path);
      await primary.writeAsString('{bozuk');

      final recovered = await store.load();
      expect(recovered.source, StoreLoadSource.temporary);
      expect(recovered.state.appLanguageTag, 'en');
      expect(await temporary.exists(), isFalse);
      expect(
        (await store.load()).state.appLanguageTag,
        'en',
        reason: 'recovered temporary state must become the new primary state',
      );
    },
  );

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

  test('yapısal olarak bozuk ana kayıt yerine sağlam yedek yüklenir', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mizan-invalid-structure-test',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = LocalStore(directory: directory);
    final state = comprehensiveState();
    await store.save(state);
    await store.save(state.copyWith(appLanguageTag: 'en'));

    final primary = File('${directory.path}/mizan_state.json');
    final envelope = jsonDecode(await primary.readAsString()) as Map;
    final stateJson = envelope['state'] as Map;
    final people = stateJson['people'] as List;
    people.add(Map<String, dynamic>.from(people.first as Map));
    await primary.writeAsString(jsonEncode(envelope), flush: true);

    final recovered = await store.load();
    expect(recovered.source, StoreLoadSource.backup);
    expect(recovered.state.appLanguageTag, 'tr');
    expect(recovered.state.people, hasLength(1));
  });
}
