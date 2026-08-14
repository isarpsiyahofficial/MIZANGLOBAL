import '../core/mizan_clock.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import '../core/localized_material.dart';

import '../controllers/mizan_controller.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../global/global_catalog.dart';
import '../models/mizan_models.dart';
import '../services/csv_backup_service.dart';
import '../widgets/global_picker_dialog.dart';
import '../widgets/mizan_cards.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, this.catalog, super.key});

  final MizanController controller;
  final GlobalCatalog? catalog;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final health = controller.notificationHealth;
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;

    return ListView(
      key: const PageStorageKey('settings'),
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 100),
      children: [
        const PageHeader(
          title: 'Ayarlar',
          subtitle:
              'Bildirim davranışı, yerel kayıt güvenliği ve yedekleme seçenekleri',
        ),
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
          title: 'Bildirim sistemi',
          subtitle:
              'Ana durumu ve Android izinlerini burada yönet. Hatırlatma saati ve mesajı ilgili kaydın ayrıntısındadır.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Bildirim sistemi açık',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  state.notificationsEnabled
                      ? 'Etkin hatırlatmalar seçilen gün ve dakikada planlanır.'
                      : 'Hatırlatmalar durdurulur; kayıtlar ve ayarlar silinmez.',
                ),
                value: state.notificationsEnabled,
                onChanged: controller.isBusy
                    ? null
                    : controller.setNotificationsEnabled,
              ),
              const Divider(height: 24),
              _SystemStatusRow(
                icon: health.permissionGranted
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                title: 'Bildirim izni',
                value: health.permissionGranted ? 'Açık' : 'Kapalı',
                ready: health.permissionGranted,
              ),
              const Divider(height: 18),
              _SystemStatusRow(
                icon: health.preciseTimingGranted
                    ? Icons.schedule_outlined
                    : Icons.timer_off_outlined,
                title: 'Dakik bildirim izni',
                value: health.preciseTimingGranted ? 'Açık' : 'Kapalı',
                ready: health.preciseTimingGranted,
              ),
              if (!health.permissionGranted ||
                  !health.preciseTimingGranted) ...[
                const SizedBox(height: 14),
                _InfoPanel(
                  icon: Icons.warning_amber_rounded,
                  title: 'Dakik teslim için izin gerekli',
                  text: !health.permissionGranted
                      ? 'Android bildirim izni kapalı. İzin açılmadan hiçbir MİZAN bildirimi oluşturulmaz.'
                      : 'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.',
                  color: MizanTheme.red,
                ),
              ],
              if (health.message case final message?) ...[
                const SizedBox(height: 14),
                _InfoPanel(
                  icon: Icons.info_outline,
                  title: 'Bildirim planı bilgisi',
                  text: message,
                  color: MizanTheme.blue,
                ),
              ],
              const SizedBox(height: 14),
              const _InfoPanel(
                icon: Icons.sync_outlined,
                title: 'Otomatik senkronizasyon',
                text:
                    'Kayıt değişiklikleri üst üste bindirilmeden sırayla işlenir. Yalnız sıradaki gerekli bildirimler dakik biçimde yenilenir; gereksiz günlük kopyalar oluşturulmaz.',
                color: MizanTheme.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'Ödeme hatırlatmaları',
          subtitle:
              'Her kart yalnız özet gösterir. Saat, mesaj ve açık/kapalı durumu karta dokununca düzenlenir.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${state.paymentNotificationSlots.length} özel bildirim saati',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  FilledButton.icon(
                    onPressed:
                        controller.isBusy ||
                            state.paymentNotificationSlots.length >= 10
                        ? null
                        : controller.addPaymentNotificationSlot,
                    icon: const Icon(Icons.notification_add_outlined),
                    label: const Text('Saat ekle'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final slot in state.paymentNotificationSlots) ...[
                _ReminderSummaryCard(
                  slot: slot,
                  color: MizanTheme.blue,
                  onTap: () => _editSlot(
                    context,
                    slot,
                    paymentSlot: true,
                    canDelete: state.paymentNotificationSlots.length > 1,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              MizanListCard(
                title: 'Ses ve titreşim',
                subtitle:
                    '${state.notificationSoundMode.label} · ${state.notificationVibrationEnabled ? 'Titreşim açık' : 'Titreşim kapalı'}',
                leadingColor: MizanTheme.ink,
                icon: Icons.tune_outlined,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editDeliveryPreferences(context),
              ),
              const SizedBox(height: 10),
              const _InfoPanel(
                icon: Icons.event_available_outlined,
                title: 'Vade kayıtları değiştirilmez',
                text:
                    'Bildirim planlaması yalnız hatırlatma oluşturur; ödeme, taksit, gider veya geçmiş kaydı üretmez.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'Günlük gider hatırlatmaları',
          subtitle:
              'Her gider hatırlatmasının saatini, mesajını ve açık/kapalı durumunu kendi ayrıntısından düzenle.',
          child: Column(
            children: [
              for (final slot in state.notificationSlots) ...[
                _ReminderSummaryCard(
                  slot: slot,
                  color: MizanTheme.green,
                  onTap: () => _editSlot(
                    context,
                    slot,
                    paymentSlot: false,
                    canDelete: false,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
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
              const SizedBox(height: 12),
              const _InfoPanel(
                icon: Icons.account_tree_outlined,
                title: 'İlişkiler korunur',
                text:
                    'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.',
              ),
            ],
          ),
        ),
      ],
    );
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

  Future<void> _editSlot(
    BuildContext context,
    NotificationSlot slot, {
    required bool paymentSlot,
    required bool canDelete,
  }) async {
    var time = TimeOfDay(hour: slot.hour, minute: slot.minute);
    var enabled = slot.enabled;
    final label = TextEditingController(text: slot.label);
    final message = TextEditingController(text: slot.message);
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            NotificationSlot candidate() => slot.copyWith(
              label: label.text.trim(),
              hour: time.hour,
              minute: time.minute,
              message: message.text.trim(),
              enabled: enabled,
            );

            return AlertDialog(
              title: Text(
                paymentSlot ? 'Hatırlatmayı düzenle' : '${slot.label} ayarları',
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Durum ve saat',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        if (paymentSlot) ...[
                          TextFormField(
                            controller: label,
                            maxLength: 60,
                            decoration: localizedInputDecoration(
                              const InputDecoration(
                                labelText: 'Hatırlatma adı',
                                prefixIcon: Icon(Icons.label_outline),
                              ),
                            ),
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 10),
                        ],
                        OutlinedButton.icon(
                          onPressed: () async {
                            final selected = await showTimePicker(
                              context: dialogContext,
                              initialTime: time,
                              helpText: 'Bildirim saatini seç',
                            );
                            if (selected != null) {
                              setDialogState(() => time = selected);
                            }
                          },
                          icon: const Icon(Icons.schedule_outlined),
                          label: Text(
                            'Saat ve dakika: ${timeLabel(time.hour, time.minute)}',
                          ),
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Hatırlatma açık',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            enabled
                                ? 'Seçilen vade günlerinde planlanır.'
                                : 'Kayıt korunur ancak bildirim oluşturulmaz.',
                          ),
                          value: enabled,
                          onChanged: (value) =>
                              setDialogState(() => enabled = value),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mesaj',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: message,
                          maxLength: 160,
                          minLines: 2,
                          maxLines: 4,
                          decoration: localizedInputDecoration(
                            const InputDecoration(
                              labelText: 'Bildirim mesajı',
                              prefixIcon: Icon(Icons.message_outlined),
                            ),
                          ),
                          validator: _requiredValidator,
                        ),
                        if (!controller
                            .notificationHealth
                            .preciseTimingGranted) ...[
                          const SizedBox(height: 10),
                          const _InfoPanel(
                            icon: Icons.timer_off_outlined,
                            title: 'Dakik bildirim izni kapalı',
                            text:
                                'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.',
                            color: MizanTheme.red,
                          ),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.isBusy
                              ? null
                              : () async {
                                  if (!(formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  try {
                                    final target = await controller
                                        .scheduleNotificationTest(candidate());
                                    if (dialogContext.mounted) {
                                      _showMessage(
                                        dialogContext,
                                        controller
                                                .notificationHealth
                                                .preciseTimingGranted
                                            ? 'Test ${timeLabel(target.hour, target.minute)} için dakik olarak planlandı.'
                                            : 'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.',
                                      );
                                    }
                                  } on Object catch (error) {
                                    if (dialogContext.mounted) {
                                      _showMessage(
                                        dialogContext,
                                        'Test planlanamadı: $error',
                                        error: true,
                                      );
                                    }
                                  }
                                },
                          icon: const Icon(Icons.notification_add_outlined),
                          label: const Text('1 dakika sonra test bildirimi'),
                        ),
                        if (paymentSlot && canDelete) ...[
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: controller.isBusy
                                ? null
                                : () async {
                                    final accepted = await _confirmDeleteSlot(
                                      dialogContext,
                                      slot.label,
                                    );
                                    if (accepted != true) return;
                                    await controller
                                        .deletePaymentNotificationSlot(slot.id);
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Bu hatırlatmayı sil'),
                            style: TextButton.styleFrom(
                              foregroundColor: MizanTheme.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: controller.isBusy
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          try {
                            if (paymentSlot) {
                              await controller.updatePaymentNotificationSlot(
                                slotId: slot.id,
                                label: label.text,
                                hour: time.hour,
                                minute: time.minute,
                                message: message.text,
                                enabled: enabled,
                              );
                            } else {
                              await controller.updateNotificationSlot(
                                slotId: slot.id,
                                hour: time.hour,
                                minute: time.minute,
                                message: message.text,
                                enabled: enabled,
                              );
                            }
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } on Object catch (error) {
                            if (dialogContext.mounted) {
                              _showMessage(
                                dialogContext,
                                'Hatırlatma kaydedilemedi: $error',
                                error: true,
                              );
                            }
                          }
                        },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      await Future<void>.delayed(kThemeAnimationDuration);
      label.dispose();
      message.dispose();
    }
  }

  Future<void> _editDeliveryPreferences(BuildContext context) async {
    var sound = controller.state.notificationSoundMode;
    var vibration = controller.state.notificationVibrationEnabled;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Ses ve titreşim davranışı'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<NotificationSoundMode>(
                    initialValue: sound,
                    isExpanded: true,
                    decoration: localizedInputDecoration(
                      const InputDecoration(
                        labelText: 'Bildirim sesi',
                        prefixIcon: Icon(Icons.volume_up_outlined),
                      ),
                    ),
                    items: [
                      for (final item in NotificationSoundMode.values)
                        DropdownMenuItem(value: item, child: Text(item.label)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => sound = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Titreşim',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Sessiz ses seçildiğinde titreşim de kullanılmaz.',
                    ),
                    value: vibration,
                    onChanged: (value) =>
                        setDialogState(() => vibration = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: controller.isBusy
                  ? null
                  : () async {
                      await controller.setNotificationSoundMode(sound);
                      await controller.setNotificationVibrationEnabled(
                        vibration,
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteSlot(BuildContext context, String label) =>
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Hatırlatmayı sil'),
          content: Text(
            '“$label” silinecek. Diğer hatırlatmalar ve kayıtlar etkilenmez.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: MizanTheme.red),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

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

  static String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Bu alan boş bırakılamaz.' : null;

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

class _ReminderSummaryCard extends StatelessWidget {
  const _ReminderSummaryCard({
    required this.slot,
    required this.color,
    required this.onTap,
  });

  final NotificationSlot slot;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (slot.enabled ? color : MizanTheme.muted).withValues(
                  alpha: .10,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: slot.enabled ? color : MizanTheme.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    timeLabel(slot.hour, slot.minute),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _SmallStatusLabel(label: 'Bildirim', color: color),
                      _SmallStatusLabel(
                        label: slot.enabled ? 'Açık' : 'Kapalı',
                        color: slot.enabled
                            ? MizanTheme.green
                            : MizanTheme.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

class _SmallStatusLabel extends StatelessWidget {
  const _SmallStatusLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    ),
  );
}

class _SystemStatusRow extends StatelessWidget {
  const _SystemStatusRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.ready,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready ? MizanTheme.green : MizanTheme.red;
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.text,
    this.color = MizanTheme.blue,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: .22)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
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
