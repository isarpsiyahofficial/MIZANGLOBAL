import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';
import 'package:lefferion_prime_mizan/services/permanent_backup_proof_guard.dart';

void main() {
  const proofA =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
  const proofB =
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
  const service = CsvBackupService();
  const guard = PermanentBackupProofGuard();

  test('matching permanent Google Play proof authorizes backup import', () {
    final content = service.exportState(
      MizanState.empty(),
      permanentPurchaseFingerprint: proofA,
    );
    final imported = guard.importVerified(
      content: content,
      currentVerifiedFingerprint: proofA,
    );
    expect(imported.permanentPurchaseFingerprint, proofA);
  });

  test('different permanent Google Play proof blocks backup import', () {
    final content = service.exportState(
      MizanState.empty(),
      permanentPurchaseFingerprint: proofA,
    );
    expect(
      () => guard.importVerified(
        content: content,
        currentVerifiedFingerprint: proofB,
      ),
      throwsA(isA<PermanentBackupProofException>()),
    );
  });

  test('legacy backup without proof requires a valid current permanent proof', () {
    final content = service.exportState(MizanState.empty());
    final imported = guard.importVerified(
      content: content,
      currentVerifiedFingerprint: proofA,
    );
    expect(imported.hasPermanentPurchaseProof, isFalse);
    expect(
      () => guard.importVerified(
        content: content,
        currentVerifiedFingerprint: 'invalid',
      ),
      throwsA(isA<PermanentBackupProofException>()),
    );
  });

  test('malformed embedded entitlement proof cannot become a legacy import', () {
    final content = service
        .exportState(
          MizanState.empty(),
          permanentPurchaseFingerprint: proofA,
        )
        .replaceAll(proofA, 'invalid-proof');
    expect(
      () => guard.importVerified(
        content: content,
        currentVerifiedFingerprint: proofA,
      ),
      throwsA(isA<PermanentBackupProofException>()),
    );
  });
}
