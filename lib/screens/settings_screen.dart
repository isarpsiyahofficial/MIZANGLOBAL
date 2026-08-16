import '../core/mizan_clock.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import '../core/localized_material.dart';

import '../controllers/mizan_controller.dart';
import '../core/theme.dart';
import '../global/global_catalog.dart';
import '../monetization/monetization_scope.dart';
import '../monetization/pro_branding.dart';
import '../services/csv_backup_service.dart';
import '../widgets/global_picker_dialog.dart';
import '../widgets/mizan_cards.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, this.catalog, super.key});

  final MizanController controller;
  final GlobalCatalog? catalog;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final monetization = MonetizationScope.maybeOf(context);
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;
    String proText(String key) =>
        ProBranding.monetizationText(MizanI18n.languageTag, key);

    return ListView(
      key: const PageStorageKey('settings'),
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 100),
      children: [
        const PageHeader(title: 'Ayarlar', subtitle: 'Yerel veri güvenliği'),
        if (monetization != null) ...[
          const SizedBox(height: 18),
          MizanListCard(
            title: proText('premium'),
            subtitle: monetization.isPermanentPremium
                ? proText('lifetimePremium')
                : monetization.isTemporaryPremium
                ? '${proText('temporaryPremium')} · '
                      '${_remainingPremium(monetization.temporaryPremiumRemaining)}'
                : proText('premiumSubtitle'),
            leadingColor: monetization.isPremium
                ? MizanTheme.green
                : MizanTheme.blue,
            icon: monetization.isPremium
                ? Icons.workspace_premium_rounded
                : Icons.workspace_premium_outlined,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PremiumScreen(controller: monetization),
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (catalog case final globalCatalog?) ...[
          _SettingsSection(
            title: 'Dil, ülke ve para birimi',
            subtitle:
                'Bu seçimleri değiştirmek kayıtları, ödemeleri veya geçmişi silmez.',
            child: Column(
              children: [
                MizanListCard(
                  title: 'Uygulama dili',
                  subtitle: _languageLabel(globalCatalog, state.appLanguageTag),
                  leadingColor: MizanTheme.blue,
                  icon: Icons.translate,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: controller.isBusy
                      ? null
                      : () => _changeLanguage(context, globalCatalog),
                ),
                const SizedBox(height: 10),
                MizanListCard(
                  title: 'Ülke / borç bölgesi',
                  subtitle: _countryLabel(
                    globalCatalog,
                    state.debtRegionCountryCode,
                  ),
                  leadingColor: MizanTheme.green,
                  icon: Icons.flag_outlined,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: controller.isBusy
                      ? null
                      : () => _changeCountry(context, globalCatalog),
                ),
                const SizedBox(height: 10),
                MizanListCard(
                  title: 'Varsayılan para birimi',
                  subtitle: _currencyLabel(
                    globalCatalog,
                    state.defaultCurrencyCode,
                  ),
                  leadingColor: MizanTheme.ink,
                  icon: Icons.currency_exchange,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: controller.isBusy
                      ? null
                      : () => _changeCurrency(context, globalCatalog),
                ),
                const SizedBox(height: 10),
                const _InfoPanel(
                  icon: Icons.shield_outlined,
                  title: 'Profil kayıtları korunur',
                  text:
                      'Dil, ülke veya varsayılan para birimi değiştiğinde mevcut kişi, borç, fatura, gider, gelir ve ödeme kayıtları değiştirilmez.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _SettingsSection(
          title: 'Yerel veri güvenliği',
          subtitle:
              'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.',
          child: const Column(
            children: [
              MizanListCard(
                title: 'Anlık yerel kayıt',
                subtitle:
                    'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.',
                leadingColor: MizanTheme.green,
                icon: Icons.save_outlined,
              ),
              SizedBox(height: 10),
              MizanListCard(
                title: 'Doğrulanmış yedek kopya',
                subtitle:
                    'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.',
                leadingColor: MizanTheme.blue,
                icon: Icons.verified_user_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'CSV yedekleme',
          subtitle:
              'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: controller.isBusy ? null : () => _exportCsv(context),
                icon: const Icon(Icons.download_outlined),
                label: const Text('CSV yedeğini dışa aktar'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: controller.isBusy ? null : () => _importCsv(context),
                icon: const Icon(Icons.merge_type_outlined),
                label: const Text('CSV yedeğini mevcut verilerle birleştir'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _remainingPremium(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 999999999).toInt();
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (days > 0) return '${days}g ${hours}s ${minutes}dk';
    return '${hours}s ${minutes}dk';
  }

  String _languageLabel(GlobalCatalog catalog, String code) {
    final item = catalog.language(code);
    return '${item.nativeName} · ${item.nameFor(MizanI18n.languageTag)}';
  }

  String _countryLabel(GlobalCatalog catalog, String code) {
    final item = catalog.country(code);
    return '${item.nameFor(MizanI18n.languageTag)} · ${item.code}';
  }

  String _currencyLabel(GlobalCatalog catalog, String code) {
    final item = catalog.currency(code);
    return '${item.code} · ${item.nameFor(MizanI18n.languageTag)}';
  }

  Future<void> _changeLanguage(
    BuildContext context,
    GlobalCatalog catalog,
  ) async {
    final selected = await showLanguagePicker(
      context,
      catalog: catalog,
      selectedCode: controller.state.appLanguageTag,
    );
    if (selected == null) return;
    await controller.updateGlobalPreferences(
      appLanguageTag: selected.code,
      debtRegionCountryCode: controller.state.debtRegionCountryCode,
      defaultCurrencyCode: controller.state.defaultCurrencyCode,
    );
  }

  Future<void> _changeCountry(
    BuildContext context,
    GlobalCatalog catalog,
  ) async {
    final selected = await showCountryPicker(
      context,
      catalog: catalog,
      selectedCode: controller.state.debtRegionCountryCode,
    );
    if (selected == null) return;
    await controller.updateGlobalPreferences(
      appLanguageTag: controller.state.appLanguageTag,
      debtRegionCountryCode: selected.code,
      defaultCurrencyCode: controller.state.defaultCurrencyCode,
    );
  }

  Future<void> _changeCurrency(
    BuildContext context,
    GlobalCatalog catalog,
  ) async {
    final selected = await showCurrencyPicker(
      context,
      catalog: catalog,
      selectedCode: controller.state.defaultCurrencyCode,
    );
    if (selected == null) return;
    await controller.updateGlobalPreferences(
      appLanguageTag: controller.state.appLanguageTag,
      debtRegionCountryCode: controller.state.debtRegionCountryCode,
      defaultCurrencyCode: selected.code,
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      const service = CsvBackupService();
      final content = service.exportState(controller.state);
      final now = MizanClock.now();
      final date =
          '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final result = await FilePicker.platform.saveFile(
        dialogTitle: MizanI18n.text('MİZAN CSV yedeğini kaydet'),
        fileName: 'MIZAN-YEDEK-$date.csv',
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        bytes: Uint8List.fromList(utf8.encode(content)),
      );
      if (context.mounted && result != null) {
        _showMessage(context, 'CSV yedeği oluşturuldu.');
      }
    } on Object catch (error) {
      if (context.mounted) {
        _showMessage(context, 'CSV yedeği oluşturulamadı: $error', error: true);
      }
    }
  }

  Future<void> _importCsv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: MizanI18n.text('MİZAN CSV yedeğini seç'),
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        throw const FormatException('Seçilen CSV dosyası okunamadı.');
      }
      const service = CsvBackupService();
      final imported = service.importState(utf8.decode(bytes));
      final mergeResult = service.mergeStates(controller.state, imported);
      if (!context.mounted) return;
      final accepted = await _confirmMerge(context, mergeResult);
      if (accepted != true) return;
      await controller.mergeFromBackup(
        mergeResult.state,
        addedCount: mergeResult.addedCount,
        mergedCount: mergeResult.mergedCount,
        duplicateCount: mergeResult.duplicateCount,
      );
      if (context.mounted) {
        _showMessage(
          context,
          '${mergeResult.addedCount} yeni kayıt eklendi; mevcut veriler korundu.',
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        _showMessage(
          context,
          'CSV yedeği birleştirilemedi: $error',
          error: true,
        );
      }
    }
  }

  Future<bool?> _confirmMerge(
    BuildContext context,
    CsvMergeResult result,
  ) => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('CSV yedeğini birleştir'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mevcut kayıtlar silinmeyecek veya yedekteki ortak verilerle yeniden yazılmayacak. Yalnız yeni kayıtlar ve eksik alt ilişkiler eklenecek.',
            ),
            const SizedBox(height: 14),
            Text('Yeni eklenecek: ${result.addedCount}'),
            Text('Eksik ilişkisi tamamlanacak: ${result.mergedCount}'),
            Text(
              result.duplicateCount == 0
                  ? 'Ortak kullanıcı kaydı: Yok'
                  : 'Ortak kullanıcı kaydı atlanacak: ${result.duplicateCount}',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Verileri birleştir'),
        ),
      ],
    ),
  );

  void _showMessage(
    BuildContext context,
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? MizanTheme.red : null,
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: MizanTheme.blue.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: MizanTheme.blue.withValues(alpha: .22)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: MizanTheme.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(text, style: const TextStyle(color: MizanTheme.muted)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ),
  );
}
