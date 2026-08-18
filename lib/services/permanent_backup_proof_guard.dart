import 'dart:convert';

import 'package:csv/csv.dart';

import '../monetization/monetization_config.dart';
import 'csv_backup_service.dart';

class PermanentBackupProofException implements Exception {
  const PermanentBackupProofException();
}

class PermanentBackupProofGuard {
  const PermanentBackupProofGuard();

  static final CsvCodec _codec = CsvCodec();

  CsvBackupEnvelope importVerified({
    required String content,
    required String currentVerifiedFingerprint,
  }) {
    final currentProof = _normalizeFingerprint(currentVerifiedFingerprint);
    if (currentProof == null) {
      throw const PermanentBackupProofException();
    }

    final rows = _codec.decode(content);
    if (rows.isEmpty) {
      throw const PermanentBackupProofException();
    }
    final header = rows.first.map((value) => value.toString()).toList();
    final formatIndex = header.indexOf('format');
    final typeIndex = header.indexOf('entity_type');
    final dataIndex = header.indexOf('data_json');
    if (formatIndex < 0 || typeIndex < 0 || dataIndex < 0) {
      throw const PermanentBackupProofException();
    }

    String? embeddedProof;
    var proofRowCount = 0;
    for (final row in rows.skip(1)) {
      if (row.length <= dataIndex ||
          row.length <= typeIndex ||
          row.length <= formatIndex ||
          row[formatIndex].toString() != CsvBackupService.formatName ||
          row[typeIndex].toString() != 'entitlement_proof') {
        continue;
      }
      proofRowCount++;
      final proof = _decodeProof(row[dataIndex].toString());
      final fingerprint = _normalizeFingerprint(
        proof['purchaseFingerprint']?.toString(),
      );
      if (proof['version'] != 1 ||
          proof['kind'] != 'google_play_non_consumable' ||
          proof['productId'] != MonetizationConfig.permanentPremiumProductId ||
          fingerprint == null) {
        throw const PermanentBackupProofException();
      }
      if (embeddedProof != null && embeddedProof != fingerprint) {
        throw const PermanentBackupProofException();
      }
      embeddedProof = fingerprint;
    }

    if (embeddedProof != null && embeddedProof != currentProof) {
      throw const PermanentBackupProofException();
    }

    final imported = const CsvBackupService().importBackup(content);
    if (proofRowCount == 0) {
      if (imported.hasPermanentPurchaseProof) {
        throw const PermanentBackupProofException();
      }
      return imported;
    }
    if (imported.permanentPurchaseFingerprint != embeddedProof) {
      throw const PermanentBackupProofException();
    }
    return imported;
  }

  Map<String, dynamic> _decodeProof(String value) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const PermanentBackupProofException();
  }

  String? _normalizeFingerprint(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || !RegExp(r'^[0-9a-f]{64}$').hasMatch(normalized)) {
      return null;
    }
    return normalized;
  }
}
