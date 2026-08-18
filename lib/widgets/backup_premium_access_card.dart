import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../l10n/mizan_i18n.dart';
import '../monetization/monetization_controller.dart';
import '../monetization/pro_branding.dart';
import '../screens/premium_screen.dart';

class BackupPremiumAccessCard extends StatelessWidget {
  const BackupPremiumAccessCard({
    required this.controller,
    required this.isPermanentPremium,
    required this.isTemporaryPremium,
    required this.busy,
    required this.onExport,
    required this.onImport,
    super.key,
  });

  final MonetizationController? controller;
  final bool isPermanentPremium;
  final bool isTemporaryPremium;
  final bool busy;
  final VoidCallback onExport;
  final VoidCallback onImport;

  String _pro(String key) =>
      ProBranding.monetizationText(MizanI18n.languageTag, key);

  String get _backupTitle => MizanI18n.text('CSV yedekleme');

  String _lockedHint() => isTemporaryPremium
      ? '${_pro('temporaryPremium')} · ${_pro('buyLifetime')} · $_backupTitle'
      : '${_pro('buyLifetime')} · $_backupTitle';

  @override
  Widget build(BuildContext context) {
    final unlocked = isPermanentPremium;
    return Card(
      key: ValueKey(unlocked ? 'backup-pro-unlocked' : 'backup-pro-locked'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: (unlocked ? MizanTheme.green : MizanTheme.blue)
                        .withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    unlocked
                        ? Icons.backup_rounded
                        : Icons.lock_outline_rounded,
                    color: unlocked ? MizanTheme.green : MizanTheme.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _backupTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unlocked
                            ? '${_pro('lifetimePremium')} · $_backupTitle'
                            : _lockedHint(),
                        style: const TextStyle(color: MizanTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              MizanI18n.text(
                'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            if (unlocked) ...[
              Container(
                key: const ValueKey('backup-pro-active-banner'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: MizanTheme.green.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: MizanTheme.green.withValues(alpha: .18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: MizanTheme.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_pro('lifetimePremium')} · $_backupTitle',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('backup-export-enabled'),
                onPressed: busy ? null : onExport,
                icon: const Icon(Icons.download_outlined),
                label: Text(MizanI18n.text('CSV yedeğini dışa aktar')),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const ValueKey('backup-import-enabled'),
                onPressed: busy ? null : onImport,
                icon: const Icon(Icons.merge_type_outlined),
                label: Text(
                  MizanI18n.text('CSV yedeğini mevcut verilerle birleştir'),
                ),
              ),
            ] else ...[
              Container(
                key: const ValueKey('backup-pro-lock-banner'),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: MizanTheme.blue.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: MizanTheme.blue.withValues(alpha: .18),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.workspace_premium_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _lockedHint(),
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const ValueKey('backup-upgrade-button'),
                onPressed: controller == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PremiumScreen(controller: controller!),
                        ),
                      ),
                icon: const Icon(Icons.workspace_premium_outlined),
                label: Text(_pro('buyLifetime')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
