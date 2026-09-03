import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path_provider/path_provider.dart';

import '../l10n/mizan_i18n.dart';
import '../models/mizan_models.dart';
import '../models/mizan_state_validator.dart';

enum StoreLoadSource { primary, temporary, backup, fresh }

class StoreLoadResult {
  StoreLoadResult({required this.state, required this.source, this.message});

  final MizanState state;
  final StoreLoadSource source;
  final String? message;
}

abstract class MizanStore {
  Future<StoreLoadResult> load();
  Future<void> save(MizanState state);
  Future<void> reset(MizanState state);
}

class LocalStore implements MizanStore {
  LocalStore({Directory? directory}) : _overrideDirectory = directory;

  static const _primaryFileName = 'mizan_state.json';
  static const _backupFileName = 'mizan_state.backup.json';
  static const _temporaryFileName = 'mizan_state.tmp.json';

  final Directory? _overrideDirectory;

  Future<Directory> _directory() async {
    final directory =
        _overrideDirectory ?? await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<File> _file(String name) async =>
      File('${(await _directory()).path}/$name');

  Future<void> _replacePrimaryWith(File source, File primary) async {
    if (await primary.exists()) {
      await primary.delete();
    }
    try {
      await source.rename(primary.path);
    } on FileSystemException {
      await source.copy(primary.path);
      if (await source.exists()) {
        await source.delete();
      }
    }
  }

  @override
  Future<StoreLoadResult> load() async {
    final primary = await _file(_primaryFileName);
    final backup = await _file(_backupFileName);
    final temporary = await _file(_temporaryFileName);
    final primaryExists = await primary.exists();
    final backupExists = await backup.exists();
    final temporaryExists = await temporary.exists();

    final primaryResult = await _tryRead(primary);
    if (primaryResult != null) {
      return StoreLoadResult(
        state: primaryResult,
        source: StoreLoadSource.primary,
      );
    }

    final temporaryResult = await _tryRead(temporary);
    if (temporaryResult != null) {
      await _replacePrimaryWith(temporary, primary);
      final verified = await _tryRead(primary);
      if (verified == null) {
        throw FileSystemException(
          MizanI18n.text(
            'Geçici kayıt doğrulanamadı.',
            languageTag: temporaryResult.appLanguageTag,
          ),
        );
      }
      return StoreLoadResult(
        state: verified,
        source: StoreLoadSource.temporary,
        message: MizanI18n.text(
          'Kesintiye uğrayan son kayıt güvenli biçimde geri yüklendi.',
          languageTag: verified.appLanguageTag,
        ),
      );
    }

    final backupResult = await _tryRead(backup);
    if (backupResult != null) {
      await backup.copy(temporary.path);
      final verified = await _tryRead(temporary);
      if (verified == null) {
        throw FileSystemException(
          MizanI18n.text(
            'Yedek kayıt doğrulanamadı.',
            languageTag: backupResult.appLanguageTag,
          ),
        );
      }
      await _replacePrimaryWith(temporary, primary);
      return StoreLoadResult(
        state: backupResult,
        source: StoreLoadSource.backup,
        message: MizanI18n.text(
          'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.',
          languageTag: backupResult.appLanguageTag,
        ),
      );
    }

    if (primaryExists || backupExists || temporaryExists) {
      throw FileSystemException(
        MizanI18n.text(
          'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.',
        ),
      );
    }

    final empty = MizanState.freshInstall();
    await save(empty);
    return StoreLoadResult(
      state: empty,
      source: StoreLoadSource.fresh,
      message: MizanI18n.text(
        'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.',
      ),
    );
  }

  Future<MizanState?> _tryRead(File file) async {
    if (!await file.exists()) {
      return null;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }
      final decoded = await Isolate.run<dynamic>(() => jsonDecode(raw));
      if (decoded is! Map) {
        return null;
      }
      final envelope = Map<String, dynamic>.from(decoded);
      final savedAt =
          DateTime.tryParse(envelope['savedAt']?.toString() ?? '')?.toLocal() ??
          (await file.lastModified()).toLocal();
      final stateJson = envelope['state'];
      final state = stateJson is Map
          ? MizanState.fromJson(Map<String, dynamic>.from(stateJson))
          : MizanState.fromJson(envelope);
      final hydrated = hydrateLegacyOverdueAnchors(state, savedAt);
      validateMizanState(hydrated);
      return hydrated;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(MizanState state) async {
    final primary = await _file(_primaryFileName);
    final backup = await _file(_backupFileName);
    final temporary = await _file(_temporaryFileName);
    final envelope = <String, dynamic>{
      'format': 'lefferion-prime-mizan',
      'schemaVersion': currentSchemaVersion,
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'state': state.copyWith(schemaVersion: currentSchemaVersion).toJson(),
    };
    final encoded = await Isolate.run<String>(() => jsonEncode(envelope));

    await temporary.writeAsString(encoded, flush: true);
    final verified = await _tryRead(temporary);
    if (verified == null) {
      await temporary.delete().catchError(
        (_) => temporary,
        test: (error) => error is FileSystemException,
      );
      throw FileSystemException(MizanI18n.text('Geçici kayıt doğrulanamadı.'));
    }

    if (await primary.exists()) {
      await primary.copy(backup.path);
    }

    await _replacePrimaryWith(temporary, primary);

    final finalVerification = await _tryRead(primary);
    if (finalVerification == null) {
      if (await backup.exists()) {
        await backup.copy(primary.path);
      }
      throw FileSystemException(
        MizanI18n.text('Kayıt doğrulaması başarısız oldu.'),
      );
    }
  }

  @override
  Future<void> reset(MizanState state) async {
    final primary = await _file(_primaryFileName);
    final backup = await _file(_backupFileName);
    final temporary = await _file(_temporaryFileName);
    for (final file in [primary, backup, temporary]) {
      if (await file.exists()) {
        await file.delete();
      }
    }
    await save(state);
  }
}
