import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../l10n/mizan_i18n.dart';
import '../monetization/monetization_controller.dart';
import '../monetization/pro_branding.dart';
import '../screens/premium_screen.dart';

class PdfPremiumAccessCard extends StatelessWidget {
  const PdfPremiumAccessCard({
    required this.controller,
    required this.isPremium,
    required this.generating,
    required this.onSave,
    required this.onShare,
    super.key,
  });

  final MonetizationController? controller;
  final bool isPremium;
  final bool generating;
  final VoidCallback onSave;
  final VoidCallback onShare;

  String _pro(String key) =>
      ProBranding.monetizationText(MizanI18n.languageTag, key);

  String _text(String key) => PdfAccessStrings.text(MizanI18n.languageTag, key);

  @override
  Widget build(BuildContext context) {
    final unlocked = isPremium;
    return Card(
      key: ValueKey(unlocked ? 'pdf-pro-unlocked' : 'pdf-pro-locked'),
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
                        ? Icons.picture_as_pdf_rounded
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
                        _text('pdfTitle'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unlocked ? _text('unlockedHint') : _text('lockedHint'),
                        style: const TextStyle(color: MizanTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (unlocked) ...[
              Container(
                key: const ValueKey('pdf-pro-active-banner'),
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
                      Icons.lock_open_rounded,
                      color: MizanTheme.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_pro('premiumActive')} · ${_pro('benefitPdf')}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('pdf-save-enabled'),
                    onPressed: generating ? null : onSave,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(
                      generating ? _text('preparing') : _text('download'),
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('pdf-share-enabled'),
                    onPressed: generating ? null : onShare,
                    icon: const Icon(Icons.share_outlined),
                    label: Text(_text('share')),
                  ),
                ],
              ),
            ] else ...[
              Container(
                key: const ValueKey('pdf-pro-lock-banner'),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _text('lockedTitle'),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _text('lockedBody'),
                            style: const TextStyle(
                              color: MizanTheme.muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    key: const ValueKey('pdf-preview-button'),
                    onPressed: () => showPdfSamplePreview(context),
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(_text('preview')),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('pdf-upgrade-button'),
                    onPressed: controller == null
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  PremiumScreen(controller: controller!),
                            ),
                          ),
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: Text(_pro('buyLifetime')),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showPdfSamplePreview(BuildContext context) => showDialog<void>(
  context: context,
  builder: (dialogContext) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    PdfAccessStrings.text(
                      MizanI18n.languageTag,
                      'previewTitle',
                    ),
                    style: Theme.of(dialogContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MizanTheme.blue.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            PdfAccessStrings.text(
                              MizanI18n.languageTag,
                              'previewNotice',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _SamplePdfPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

class _SamplePdfPage extends StatelessWidget {
  const _SamplePdfPage();

  String _ui(String turkish) => MizanI18n.text(turkish);

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1 / 1.414,
    child: Container(
      key: const ValueKey('pdf-sample-page'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFDDE3EC)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 6),
            color: Color(0x16000000),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Color(0xFF172033), fontSize: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'LEFFERION PRIME · MİZAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2459B3),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _ui('Aylık finans raporu'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              '${_ui('Dönem')}: 01.08.2026 – 31.08.2026',
              style: const TextStyle(color: Color(0xFF667085)),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _SampleSummaryRow(label: _ui('Gelir'), value: '42.000 TRY'),
            _SampleSummaryRow(label: _ui('Ödemeler'), value: '11.850 TRY'),
            _SampleSummaryRow(
              label: _ui('Normal giderler'),
              value: '7.320 TRY',
            ),
            _SampleSummaryRow(
              label: _ui('Kalan ödeme yükü'),
              value: '18.400 TRY',
            ),
            const SizedBox(height: 12),
            Text(
              _ui('Gerçekleşen harcamaların dağılımı'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const _SampleBar(label: '#1', value: '6.250 TRY', factor: .82),
            const _SampleBar(label: '#2', value: '3.480 TRY', factor: .56),
            const _SampleBar(label: '#3', value: '2.120 TRY', factor: .38),
            const SizedBox(height: 12),
            Text(
              _ui('Gerçekleşen ödeme ayrıntıları'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const _SampleLine(title: '#1', value: '4.500 TRY'),
            const _SampleLine(title: '#2', value: '1.350 TRY'),
            const _SampleLine(title: '#3', value: '6.000 TRY'),
            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 6),
            const Text(
              'LEFFERION PRIME · MİZAN · 1',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF667085), fontSize: 9),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SampleSummaryRow extends StatelessWidget {
  const _SampleSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class _SampleBar extends StatelessWidget {
  const _SampleBar({
    required this.label,
    required this.value,
    required this.factor,
  });

  final String label;
  final String value;
  final double factor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(value: factor, minHeight: 5),
        ),
      ],
    ),
  );
}

class _SampleLine extends StatelessWidget {
  const _SampleLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.receipt_long_outlined, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(title)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

abstract final class PdfAccessStrings {
  static const _values = <String, Map<String, String>>{
    'tr': {
      'pdfTitle': 'PDF raporları',
      'lockedTitle': 'PDF raporları PRO ile açılır',
      'lockedHint':
          'PDF raporlarını kaydetme ve paylaşma PRO erişimine dahildir.',
      'lockedBody':
          'Raporlarını düzenli bir PDF dosyası olarak kaydetmek ve paylaşmak için PRO erişimini açabilirsin. Satın almadan önce örnek raporu inceleyebilirsin.',
      'unlockedHint':
          'PRO aktif. Raporunu PDF olarak kaydedebilir veya paylaşabilirsin.',
      'preview': 'Önizleme',
      'previewTitle': 'Örnek PDF önizlemesi',
      'previewNotice':
          'Bu yalnızca örnek bir rapordur. Kendi kayıtların kullanılmaz ve bu önizleme PDF dışa aktarma hakkı vermez.',
      'download': 'PDF indir',
      'share': 'PDF paylaş',
      'preparing': 'PDF hazırlanıyor',
    },
    'en': {
      'pdfTitle': 'PDF reports',
      'lockedTitle': 'PDF reports unlock with PRO',
      'lockedHint':
          'Saving and sharing PDF reports is included with PRO access.',
      'lockedBody':
          'Unlock PRO to save and share your reports as a structured PDF. You can review a sample report before purchasing.',
      'unlockedHint':
          'PRO is active. You can save or share your report as a PDF.',
      'preview': 'Preview',
      'previewTitle': 'Sample PDF preview',
      'previewNotice':
          'This is a sample report only. Your records are not used and this preview does not grant PDF export access.',
      'download': 'Download PDF',
      'share': 'Share PDF',
      'preparing': 'Preparing PDF',
    },
    'es': {
      'pdfTitle': 'Informes PDF',
      'lockedTitle': 'Los informes PDF se desbloquean con PRO',
      'lockedHint': 'Guardar y compartir informes PDF está incluido con PRO.',
      'lockedBody':
          'Activa PRO para guardar y compartir tus informes como PDF estructurados. Puedes revisar un informe de ejemplo antes de comprar.',
      'unlockedHint':
          'PRO está activo. Puedes guardar o compartir tu informe en PDF.',
      'preview': 'Vista previa',
      'previewTitle': 'Vista previa de PDF de ejemplo',
      'previewNotice':
          'Este es solo un informe de ejemplo. No se usan tus datos y la vista previa no habilita la exportación PDF.',
      'download': 'Descargar PDF',
      'share': 'Compartir PDF',
      'preparing': 'Preparando PDF',
    },
    'pt-BR': {
      'pdfTitle': 'Relatórios em PDF',
      'lockedTitle': 'Relatórios em PDF são liberados com PRO',
      'lockedHint': 'Salvar e compartilhar relatórios em PDF faz parte do PRO.',
      'lockedBody':
          'Ative o PRO para salvar e compartilhar seus relatórios em um PDF organizado. Você pode ver um exemplo antes da compra.',
      'unlockedHint':
          'PRO ativo. Você pode salvar ou compartilhar o relatório em PDF.',
      'preview': 'Prévia',
      'previewTitle': 'Prévia de PDF de exemplo',
      'previewNotice':
          'Este é apenas um relatório de exemplo. Seus dados não são usados e a prévia não libera a exportação em PDF.',
      'download': 'Baixar PDF',
      'share': 'Compartilhar PDF',
      'preparing': 'Preparando PDF',
    },
    'pt-PT': {
      'pdfTitle': 'Relatórios PDF',
      'lockedTitle': 'Os relatórios PDF são desbloqueados com PRO',
      'lockedHint': 'Guardar e partilhar relatórios PDF está incluído no PRO.',
      'lockedBody':
          'Ative o PRO para guardar e partilhar os seus relatórios num PDF organizado. Pode ver um exemplo antes da compra.',
      'unlockedHint':
          'PRO ativo. Pode guardar ou partilhar o relatório em PDF.',
      'preview': 'Pré-visualizar',
      'previewTitle': 'Pré-visualização de PDF de exemplo',
      'previewNotice':
          'Este é apenas um relatório de exemplo. Os seus dados não são utilizados e a pré-visualização não permite exportar PDF.',
      'download': 'Transferir PDF',
      'share': 'Partilhar PDF',
      'preparing': 'A preparar PDF',
    },
    'fr': {
      'pdfTitle': 'Rapports PDF',
      'lockedTitle': 'Les rapports PDF se débloquent avec PRO',
      'lockedHint':
          'L’enregistrement et le partage des rapports PDF sont inclus avec PRO.',
      'lockedBody':
          'Activez PRO pour enregistrer et partager vos rapports dans un PDF structuré. Vous pouvez consulter un exemple avant l’achat.',
      'unlockedHint':
          'PRO est actif. Vous pouvez enregistrer ou partager votre rapport en PDF.',
      'preview': 'Aperçu',
      'previewTitle': 'Aperçu d’un PDF exemple',
      'previewNotice':
          'Il s’agit uniquement d’un exemple. Vos données ne sont pas utilisées et cet aperçu ne donne pas accès à l’export PDF.',
      'download': 'Télécharger le PDF',
      'share': 'Partager le PDF',
      'preparing': 'Préparation du PDF',
    },
    'de': {
      'pdfTitle': 'PDF-Berichte',
      'lockedTitle': 'PDF-Berichte werden mit PRO freigeschaltet',
      'lockedHint':
          'Speichern und Teilen von PDF-Berichten ist in PRO enthalten.',
      'lockedBody':
          'Aktiviere PRO, um Berichte als strukturiertes PDF zu speichern und zu teilen. Vor dem Kauf kannst du einen Beispielbericht ansehen.',
      'unlockedHint':
          'PRO ist aktiv. Du kannst den Bericht als PDF speichern oder teilen.',
      'preview': 'Vorschau',
      'previewTitle': 'Beispiel-PDF-Vorschau',
      'previewNotice':
          'Dies ist nur ein Beispielbericht. Deine Daten werden nicht verwendet und die Vorschau schaltet den PDF-Export nicht frei.',
      'download': 'PDF herunterladen',
      'share': 'PDF teilen',
      'preparing': 'PDF wird erstellt',
    },
    'it': {
      'pdfTitle': 'Report PDF',
      'lockedTitle': 'I report PDF si sbloccano con PRO',
      'lockedHint': 'Salvare e condividere report PDF è incluso in PRO.',
      'lockedBody':
          'Attiva PRO per salvare e condividere i report come PDF strutturati. Puoi vedere un esempio prima dell’acquisto.',
      'unlockedHint':
          'PRO è attivo. Puoi salvare o condividere il report in PDF.',
      'preview': 'Anteprima',
      'previewTitle': 'Anteprima PDF di esempio',
      'previewNotice':
          'Questo è solo un report di esempio. I tuoi dati non vengono usati e l’anteprima non abilita l’esportazione PDF.',
      'download': 'Scarica PDF',
      'share': 'Condividi PDF',
      'preparing': 'Preparazione PDF',
    },
    'nl': {
      'pdfTitle': 'PDF-rapporten',
      'lockedTitle': 'PDF-rapporten worden ontgrendeld met PRO',
      'lockedHint': 'PDF-rapporten opslaan en delen is inbegrepen bij PRO.',
      'lockedBody':
          'Activeer PRO om rapporten als een gestructureerde PDF op te slaan en te delen. Je kunt vóór aankoop een voorbeeld bekijken.',
      'unlockedHint':
          'PRO is actief. Je kunt je rapport als PDF opslaan of delen.',
      'preview': 'Voorbeeld',
      'previewTitle': 'Voorbeeld van PDF-rapport',
      'previewNotice':
          'Dit is alleen een voorbeeldrapport. Je gegevens worden niet gebruikt en het voorbeeld geeft geen PDF-exporttoegang.',
      'download': 'PDF downloaden',
      'share': 'PDF delen',
      'preparing': 'PDF voorbereiden',
    },
    'pl': {
      'pdfTitle': 'Raporty PDF',
      'lockedTitle': 'Raporty PDF odblokowuje PRO',
      'lockedHint':
          'Zapisywanie i udostępnianie raportów PDF jest częścią PRO.',
      'lockedBody':
          'Włącz PRO, aby zapisywać i udostępniać raporty jako uporządkowane pliki PDF. Przed zakupem możesz zobaczyć przykład.',
      'unlockedHint':
          'PRO jest aktywne. Możesz zapisać lub udostępnić raport PDF.',
      'preview': 'Podgląd',
      'previewTitle': 'Podgląd przykładowego PDF',
      'previewNotice':
          'To tylko przykładowy raport. Twoje dane nie są używane, a podgląd nie odblokowuje eksportu PDF.',
      'download': 'Pobierz PDF',
      'share': 'Udostępnij PDF',
      'preparing': 'Przygotowywanie PDF',
    },
    'ro': {
      'pdfTitle': 'Rapoarte PDF',
      'lockedTitle': 'Rapoartele PDF se deblochează cu PRO',
      'lockedHint':
          'Salvarea și partajarea rapoartelor PDF este inclusă în PRO.',
      'lockedBody':
          'Activează PRO pentru a salva și partaja rapoartele ca PDF structurat. Poți vedea un exemplu înainte de cumpărare.',
      'unlockedHint': 'PRO este activ. Poți salva sau partaja raportul în PDF.',
      'preview': 'Previzualizare',
      'previewTitle': 'Previzualizare PDF exemplu',
      'previewNotice':
          'Acesta este doar un raport exemplu. Datele tale nu sunt folosite, iar previzualizarea nu activează exportul PDF.',
      'download': 'Descarcă PDF',
      'share': 'Partajează PDF',
      'preparing': 'Se pregătește PDF-ul',
    },
    'el': {
      'pdfTitle': 'Αναφορές PDF',
      'lockedTitle': 'Οι αναφορές PDF ξεκλειδώνουν με PRO',
      'lockedHint':
          'Η αποθήκευση και κοινοποίηση αναφορών PDF περιλαμβάνεται στο PRO.',
      'lockedBody':
          'Ενεργοποίησε το PRO για αποθήκευση και κοινοποίηση δομημένων αναφορών PDF. Μπορείς να δεις δείγμα πριν την αγορά.',
      'unlockedHint':
          'Το PRO είναι ενεργό. Μπορείς να αποθηκεύσεις ή να κοινοποιήσεις την αναφορά PDF.',
      'preview': 'Προεπισκόπηση',
      'previewTitle': 'Προεπισκόπηση δείγματος PDF',
      'previewNotice':
          'Αυτό είναι μόνο δείγμα αναφοράς. Τα δεδομένα σου δεν χρησιμοποιούνται και η προεπισκόπηση δεν ενεργοποιεί την εξαγωγή PDF.',
      'download': 'Λήψη PDF',
      'share': 'Κοινοποίηση PDF',
      'preparing': 'Προετοιμασία PDF',
    },
    'ru': {
      'pdfTitle': 'PDF-отчёты',
      'lockedTitle': 'PDF-отчёты открываются с PRO',
      'lockedHint': 'Сохранение и отправка PDF-отчётов входит в PRO.',
      'lockedBody':
          'Активируйте PRO, чтобы сохранять и отправлять структурированные PDF-отчёты. Перед покупкой можно посмотреть пример.',
      'unlockedHint': 'PRO активен. Отчёт можно сохранить или отправить в PDF.',
      'preview': 'Предпросмотр',
      'previewTitle': 'Предпросмотр примера PDF',
      'previewNotice':
          'Это только пример отчёта. Ваши данные не используются, и предпросмотр не открывает экспорт PDF.',
      'download': 'Скачать PDF',
      'share': 'Поделиться PDF',
      'preparing': 'Подготовка PDF',
    },
    'uk': {
      'pdfTitle': 'PDF-звіти',
      'lockedTitle': 'PDF-звіти відкриваються з PRO',
      'lockedHint': 'Збереження та поширення PDF-звітів входить до PRO.',
      'lockedBody':
          'Увімкніть PRO, щоб зберігати й поширювати структуровані PDF-звіти. Перед покупкою можна переглянути приклад.',
      'unlockedHint': 'PRO активний. Звіт можна зберегти або поширити у PDF.',
      'preview': 'Попередній перегляд',
      'previewTitle': 'Перегляд прикладу PDF',
      'previewNotice':
          'Це лише приклад звіту. Ваші дані не використовуються, а перегляд не відкриває експорт PDF.',
      'download': 'Завантажити PDF',
      'share': 'Поділитися PDF',
      'preparing': 'Підготовка PDF',
    },
    'ar': {
      'pdfTitle': 'تقارير PDF',
      'lockedTitle': 'تُفتح تقارير PDF مع PRO',
      'lockedHint': 'حفظ تقارير PDF ومشاركتها مشمول في PRO.',
      'lockedBody':
          'فعّل PRO لحفظ تقاريرك ومشاركتها كملف PDF منظم. يمكنك معاينة تقرير تجريبي قبل الشراء.',
      'unlockedHint': 'PRO مفعّل. يمكنك حفظ التقرير أو مشاركته بصيغة PDF.',
      'preview': 'معاينة',
      'previewTitle': 'معاينة نموذج PDF',
      'previewNotice':
          'هذا تقرير تجريبي فقط. لا تُستخدم بياناتك ولا تمنح المعاينة صلاحية تصدير PDF.',
      'download': 'تنزيل PDF',
      'share': 'مشاركة PDF',
      'preparing': 'جارٍ إعداد PDF',
    },
    'fa': {
      'pdfTitle': 'گزارش‌های PDF',
      'lockedTitle': 'گزارش‌های PDF با PRO باز می‌شوند',
      'lockedHint': 'ذخیره و اشتراک‌گذاری گزارش PDF در PRO ارائه می‌شود.',
      'lockedBody':
          'با فعال‌کردن PRO گزارش‌ها را به‌صورت PDF منظم ذخیره و اشتراک‌گذاری کنید. پیش از خرید می‌توانید نمونه را ببینید.',
      'unlockedHint':
          'PRO فعال است. می‌توانید گزارش را به‌صورت PDF ذخیره یا اشتراک‌گذاری کنید.',
      'preview': 'پیش‌نمایش',
      'previewTitle': 'پیش‌نمایش نمونه PDF',
      'previewNotice':
          'این فقط یک گزارش نمونه است. داده‌های شما استفاده نمی‌شوند و پیش‌نمایش دسترسی خروجی PDF را فعال نمی‌کند.',
      'download': 'دانلود PDF',
      'share': 'اشتراک PDF',
      'preparing': 'در حال آماده‌سازی PDF',
    },
    'he': {
      'pdfTitle': 'דוחות PDF',
      'lockedTitle': 'דוחות PDF נפתחים עם PRO',
      'lockedHint': 'שמירה ושיתוף של דוחות PDF כלולים ב-PRO.',
      'lockedBody':
          'הפעלת PRO מאפשרת לשמור ולשתף דוחות כ-PDF מסודר. אפשר לראות דוגמה לפני הרכישה.',
      'unlockedHint': 'PRO פעיל. אפשר לשמור או לשתף את הדוח כ-PDF.',
      'preview': 'תצוגה מקדימה',
      'previewTitle': 'תצוגה מקדימה של PDF לדוגמה',
      'previewNotice':
          'זהו דוח לדוגמה בלבד. הנתונים שלך אינם בשימוש והתצוגה אינה פותחת ייצוא PDF.',
      'download': 'הורדת PDF',
      'share': 'שיתוף PDF',
      'preparing': 'מכין PDF',
    },
    'hi': {
      'pdfTitle': 'PDF रिपोर्ट',
      'lockedTitle': 'PDF रिपोर्ट PRO के साथ खुलती हैं',
      'lockedHint': 'PDF रिपोर्ट सहेजना और साझा करना PRO में शामिल है.',
      'lockedBody':
          'रिपोर्ट को व्यवस्थित PDF के रूप में सहेजने और साझा करने के लिए PRO सक्रिय करें. खरीदने से पहले नमूना देख सकते हैं.',
      'unlockedHint': 'PRO सक्रिय है. आप PDF रिपोर्ट सहेज या साझा कर सकते हैं.',
      'preview': 'पूर्वावलोकन',
      'previewTitle': 'नमूना PDF पूर्वावलोकन',
      'previewNotice':
          'यह केवल नमूना रिपोर्ट है. आपके डेटा का उपयोग नहीं होता और यह पूर्वावलोकन PDF निर्यात नहीं खोलता.',
      'download': 'PDF डाउनलोड',
      'share': 'PDF साझा करें',
      'preparing': 'PDF तैयार हो रहा है',
    },
    'bn': {
      'pdfTitle': 'PDF রিপোর্ট',
      'lockedTitle': 'PDF রিপোর্ট PRO দিয়ে খুলবে',
      'lockedHint': 'PDF রিপোর্ট সংরক্ষণ ও শেয়ার করা PRO-এর অন্তর্ভুক্ত।',
      'lockedBody':
          'রিপোর্টকে সাজানো PDF হিসেবে সংরক্ষণ ও শেয়ার করতে PRO চালু করুন। কেনার আগে একটি নমুনা দেখতে পারেন।',
      'unlockedHint':
          'PRO সক্রিয়। আপনি PDF রিপোর্ট সংরক্ষণ বা শেয়ার করতে পারেন।',
      'preview': 'প্রিভিউ',
      'previewTitle': 'নমুনা PDF প্রিভিউ',
      'previewNotice':
          'এটি শুধু একটি নমুনা রিপোর্ট। আপনার তথ্য ব্যবহার করা হয় না এবং প্রিভিউ PDF এক্সপোর্ট চালু করে না।',
      'download': 'PDF ডাউনলোড',
      'share': 'PDF শেয়ার',
      'preparing': 'PDF প্রস্তুত হচ্ছে',
    },
    'ur': {
      'pdfTitle': 'PDF رپورٹس',
      'lockedTitle': 'PDF رپورٹس PRO کے ساتھ کھلتی ہیں',
      'lockedHint': 'PDF رپورٹس محفوظ اور شیئر کرنا PRO میں شامل ہے۔',
      'lockedBody':
          'رپورٹس کو منظم PDF کی صورت میں محفوظ اور شیئر کرنے کے لیے PRO فعال کریں۔ خریدنے سے پہلے نمونہ دیکھ سکتے ہیں۔',
      'unlockedHint': 'PRO فعال ہے۔ آپ PDF رپورٹ محفوظ یا شیئر کر سکتے ہیں۔',
      'preview': 'پیش منظر',
      'previewTitle': 'نمونہ PDF پیش منظر',
      'previewNotice':
          'یہ صرف نمونہ رپورٹ ہے۔ آپ کا ڈیٹا استعمال نہیں ہوتا اور یہ پیش منظر PDF ایکسپورٹ کی اجازت نہیں دیتا۔',
      'download': 'PDF ڈاؤن لوڈ',
      'share': 'PDF شیئر کریں',
      'preparing': 'PDF تیار ہو رہا ہے',
    },
    'id': {
      'pdfTitle': 'Laporan PDF',
      'lockedTitle': 'Laporan PDF terbuka dengan PRO',
      'lockedHint': 'Menyimpan dan membagikan laporan PDF termasuk dalam PRO.',
      'lockedBody':
          'Aktifkan PRO untuk menyimpan dan membagikan laporan sebagai PDF terstruktur. Anda dapat melihat contoh sebelum membeli.',
      'unlockedHint':
          'PRO aktif. Anda dapat menyimpan atau membagikan laporan PDF.',
      'preview': 'Pratinjau',
      'previewTitle': 'Pratinjau contoh PDF',
      'previewNotice':
          'Ini hanya laporan contoh. Data Anda tidak digunakan dan pratinjau tidak membuka ekspor PDF.',
      'download': 'Unduh PDF',
      'share': 'Bagikan PDF',
      'preparing': 'Menyiapkan PDF',
    },
    'ms': {
      'pdfTitle': 'Laporan PDF',
      'lockedTitle': 'Laporan PDF dibuka dengan PRO',
      'lockedHint': 'Menyimpan dan berkongsi laporan PDF termasuk dalam PRO.',
      'lockedBody':
          'Aktifkan PRO untuk menyimpan dan berkongsi laporan sebagai PDF tersusun. Anda boleh melihat contoh sebelum membeli.',
      'unlockedHint':
          'PRO aktif. Anda boleh menyimpan atau berkongsi laporan PDF.',
      'preview': 'Pratonton',
      'previewTitle': 'Pratonton contoh PDF',
      'previewNotice':
          'Ini hanya laporan contoh. Data anda tidak digunakan dan pratonton tidak membuka eksport PDF.',
      'download': 'Muat turun PDF',
      'share': 'Kongsi PDF',
      'preparing': 'Menyediakan PDF',
    },
    'fil': {
      'pdfTitle': 'Mga PDF report',
      'lockedTitle': 'Nabubuksan ang PDF reports sa PRO',
      'lockedHint': 'Kasama sa PRO ang pag-save at pagbabahagi ng PDF reports.',
      'lockedBody':
          'I-activate ang PRO para ma-save at maibahagi ang reports bilang maayos na PDF. Maaari kang tumingin ng halimbawa bago bumili.',
      'unlockedHint':
          'Aktibo ang PRO. Maaari mong i-save o ibahagi ang PDF report.',
      'preview': 'Preview',
      'previewTitle': 'Halimbawang PDF preview',
      'previewNotice':
          'Halimbawang report lamang ito. Hindi ginagamit ang data mo at hindi nagbubukas ng PDF export ang preview.',
      'download': 'I-download ang PDF',
      'share': 'Ibahagi ang PDF',
      'preparing': 'Inihahanda ang PDF',
    },
    'ko': {
      'pdfTitle': 'PDF 보고서',
      'lockedTitle': 'PDF 보고서는 PRO에서 열립니다',
      'lockedHint': 'PDF 보고서 저장 및 공유는 PRO에 포함됩니다.',
      'lockedBody':
          'PRO를 활성화하면 보고서를 정리된 PDF로 저장하고 공유할 수 있습니다. 구매 전에 예시를 확인할 수 있습니다.',
      'unlockedHint': 'PRO가 활성화되었습니다. PDF 보고서를 저장하거나 공유할 수 있습니다.',
      'preview': '미리보기',
      'previewTitle': '샘플 PDF 미리보기',
      'previewNotice':
          '이 화면은 샘플 보고서입니다. 사용자 데이터는 사용되지 않으며 미리보기는 PDF 내보내기 권한을 제공하지 않습니다.',
      'download': 'PDF 다운로드',
      'share': 'PDF 공유',
      'preparing': 'PDF 준비 중',
    },
    'ja': {
      'pdfTitle': 'PDFレポート',
      'lockedTitle': 'PDFレポートはPROで利用できます',
      'lockedHint': 'PDFレポートの保存と共有はPROに含まれます。',
      'lockedBody': 'PROを有効にすると、整理されたPDFとしてレポートを保存・共有できます。購入前にサンプルを確認できます。',
      'unlockedHint': 'PROが有効です。PDFレポートを保存または共有できます。',
      'preview': 'プレビュー',
      'previewTitle': 'サンプルPDFプレビュー',
      'previewNotice': 'これはサンプルレポートです。あなたのデータは使用されず、プレビューではPDF書き出しは有効になりません。',
      'download': 'PDFを保存',
      'share': 'PDFを共有',
      'preparing': 'PDFを準備中',
    },
    'zh': {
      'pdfTitle': 'PDF 报告',
      'lockedTitle': 'PDF 报告可通过 PRO 解锁',
      'lockedHint': '保存和分享 PDF 报告包含在 PRO 中。',
      'lockedBody': '启用 PRO 后可将报告保存并分享为结构化 PDF。购买前可以先查看示例。',
      'unlockedHint': 'PRO 已启用。你可以保存或分享 PDF 报告。',
      'preview': '预览',
      'previewTitle': '示例 PDF 预览',
      'previewNotice': '这只是示例报告，不会使用你的数据，预览也不会开放 PDF 导出权限。',
      'download': '下载 PDF',
      'share': '分享 PDF',
      'preparing': '正在准备 PDF',
    },
    'vi': {
      'pdfTitle': 'Báo cáo PDF',
      'lockedTitle': 'Báo cáo PDF được mở bằng PRO',
      'lockedHint': 'Lưu và chia sẻ báo cáo PDF nằm trong PRO.',
      'lockedBody':
          'Bật PRO để lưu và chia sẻ báo cáo dưới dạng PDF có cấu trúc. Bạn có thể xem mẫu trước khi mua.',
      'unlockedHint':
          'PRO đang hoạt động. Bạn có thể lưu hoặc chia sẻ báo cáo PDF.',
      'preview': 'Xem trước',
      'previewTitle': 'Xem trước PDF mẫu',
      'previewNotice':
          'Đây chỉ là báo cáo mẫu. Dữ liệu của bạn không được sử dụng và bản xem trước không mở quyền xuất PDF.',
      'download': 'Tải PDF',
      'share': 'Chia sẻ PDF',
      'preparing': 'Đang chuẩn bị PDF',
    },
    'th': {
      'pdfTitle': 'รายงาน PDF',
      'lockedTitle': 'รายงาน PDF ปลดล็อกด้วย PRO',
      'lockedHint': 'การบันทึกและแชร์รายงาน PDF รวมอยู่ใน PRO',
      'lockedBody':
          'เปิดใช้ PRO เพื่อบันทึกและแชร์รายงานเป็น PDF ที่จัดรูปแบบไว้ คุณสามารถดูตัวอย่างก่อนซื้อได้',
      'unlockedHint':
          'PRO เปิดใช้งานแล้ว คุณสามารถบันทึกหรือแชร์รายงาน PDF ได้',
      'preview': 'ดูตัวอย่าง',
      'previewTitle': 'ตัวอย่าง PDF',
      'previewNotice':
          'นี่เป็นเพียงรายงานตัวอย่าง ระบบจะไม่ใช้ข้อมูลของคุณ และการดูตัวอย่างไม่ได้เปิดสิทธิ์ส่งออก PDF',
      'download': 'ดาวน์โหลด PDF',
      'share': 'แชร์ PDF',
      'preparing': 'กำลังเตรียม PDF',
    },
    'sw': {
      'pdfTitle': 'Ripoti za PDF',
      'lockedTitle': 'Ripoti za PDF hufunguliwa kwa PRO',
      'lockedHint':
          'Kuhifadhi na kushiriki ripoti za PDF kunajumuishwa kwenye PRO.',
      'lockedBody':
          'Washa PRO ili kuhifadhi na kushiriki ripoti kama PDF iliyopangwa. Unaweza kuona mfano kabla ya kununua.',
      'unlockedHint':
          'PRO imewashwa. Unaweza kuhifadhi au kushiriki ripoti ya PDF.',
      'preview': 'Hakiki',
      'previewTitle': 'Hakiki ya PDF ya mfano',
      'previewNotice':
          'Hii ni ripoti ya mfano tu. Data yako haitumiki na hakiki haifungui ruhusa ya kuhamisha PDF.',
      'download': 'Pakua PDF',
      'share': 'Shiriki PDF',
      'preparing': 'Inaandaa PDF',
    },
  };

  static String text(String languageTag, String key) {
    final tag = MizanI18n.normalizeLanguageTag(languageTag);
    return _values[tag]?[key] ?? _values['en']![key] ?? key;
  }

  static Set<String> get supportedLanguageTags => _values.keys.toSet();
}
