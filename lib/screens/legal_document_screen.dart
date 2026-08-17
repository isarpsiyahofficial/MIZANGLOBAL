import 'package:flutter/material.dart';

import '../l10n/mizan_i18n.dart';
import '../legal/legal_consent_strings.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_locale_summaries.dart';
import '../legal/legal_turkish_documents.dart';
import '../monetization/pro_branding.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    required this.type,
    this.requireReadToEnd = false,
    super.key,
  });

  final LegalDocumentType type;
  final bool requireReadToEnd;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _reachedEnd = false;

  String get _languageTag => MizanI18n.languageTag;
  String _consent(String key) => LegalConsentStrings.text(_languageTag, key);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (_reachedEnd || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - 24) {
      if (mounted) setState(() => _reachedEnd = true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  String get _localizedTitle => switch (widget.type) {
    LegalDocumentType.privacy => switch (_languageTag) {
      'tr' => 'Gizlilik Politikası',
      'es' => 'Política de privacidad',
      'pt-BR' || 'pt-PT' => 'Política de Privacidade',
      'fr' => 'Politique de confidentialité',
      'de' => 'Datenschutzerklärung',
      'it' => 'Informativa sulla privacy',
      'nl' => 'Privacybeleid',
      'pl' => 'Polityka prywatności',
      'ro' => 'Politica de confidențialitate',
      'el' => 'Πολιτική απορρήτου',
      'ru' => 'Политика конфиденциальности',
      'uk' => 'Політика конфіденційності',
      'ar' => 'سياسة الخصوصية',
      'fa' => 'سیاست حریم خصوصی',
      'he' => 'מדיניות פרטיות',
      'hi' => 'गोपनीयता नीति',
      'bn' => 'গোপনীয়তা নীতি',
      'ur' => 'رازداری کی پالیسی',
      'id' => 'Kebijakan Privasi',
      'ms' => 'Dasar Privasi',
      'fil' => 'Patakaran sa Privacy',
      'ko' => '개인정보 처리방침',
      'ja' => 'プライバシーポリシー',
      'zh' => '隐私政策',
      'vi' => 'Chính sách quyền riêng tư',
      'th' => 'นโยบายความเป็นส่วนตัว',
      'sw' => 'Sera ya Faragha',
      _ => 'Privacy Policy',
    },
    LegalDocumentType.terms => switch (_languageTag) {
      'tr' => 'Kullanım Koşulları',
      'es' => 'Términos de uso',
      'pt-BR' => 'Termos de Uso',
      'pt-PT' => 'Termos de Utilização',
      'fr' => 'Conditions d’utilisation',
      'de' => 'Nutzungsbedingungen',
      'it' => 'Condizioni d’uso',
      'nl' => 'Gebruiksvoorwaarden',
      'pl' => 'Warunki użytkowania',
      'ro' => 'Condiții de utilizare',
      'el' => 'Όροι χρήσης',
      'ru' => 'Условия использования',
      'uk' => 'Умови використання',
      'ar' => 'شروط الاستخدام',
      'fa' => 'شرایط استفاده',
      'he' => 'תנאי שימוש',
      'hi' => 'उपयोग की शर्तें',
      'bn' => 'ব্যবহারের শর্তাবলি',
      'ur' => 'استعمال کی شرائط',
      'id' => 'Ketentuan Penggunaan',
      'ms' => 'Terma Penggunaan',
      'fil' => 'Mga Tuntunin ng Paggamit',
      'ko' => '이용약관',
      'ja' => '利用規約',
      'zh' => '使用条款',
      'vi' => 'Điều khoản sử dụng',
      'th' => 'ข้อกำหนดการใช้งาน',
      'sw' => 'Masharti ya Matumizi',
      _ => 'Terms of Use',
    },
    LegalDocumentType.purchase => switch (_languageTag) {
      'tr' => 'Satın Alma Koşulları',
      'es' => 'Condiciones de compra',
      'pt-BR' || 'pt-PT' => 'Termos de Compra',
      'fr' => 'Conditions d’achat',
      'de' => 'Kaufbedingungen',
      'it' => 'Condizioni di acquisto',
      'nl' => 'Aankoopvoorwaarden',
      'pl' => 'Warunki zakupu',
      'ro' => 'Condiții de achiziție',
      'el' => 'Όροι αγοράς',
      'ru' => 'Условия покупки',
      'uk' => 'Умови придбання',
      'ar' => 'شروط الشراء',
      'fa' => 'شرایط خرید',
      'he' => 'תנאי רכישה',
      'hi' => 'खरीद की शर्तें',
      'bn' => 'ক্রয়ের শর্তাবলি',
      'ur' => 'خریداری کی شرائط',
      'id' => 'Ketentuan Pembelian',
      'ms' => 'Terma Pembelian',
      'fil' => 'Mga Tuntunin sa Pagbili',
      'ko' => '구매 조건',
      'ja' => '購入条件',
      'zh' => '购买条款',
      'vi' => 'Điều khoản mua hàng',
      'th' => 'ข้อกำหนดการซื้อ',
      'sw' => 'Masharti ya Ununuzi',
      _ => 'Purchase Terms',
    },
  };

  String get _localizedSectionTitle => switch (_languageTag) {
    'tr' => 'Kendi dilinizde açıklama',
    'es' => 'Explicación en tu idioma',
    'pt-BR' || 'pt-PT' => 'Explicação no seu idioma',
    'fr' => 'Explication dans votre langue',
    'de' => 'Erklärung in Ihrer Sprache',
    'it' => 'Spiegazione nella tua lingua',
    'nl' => 'Uitleg in uw taal',
    'pl' => 'Wyjaśnienie w Twoim języku',
    'ro' => 'Explicație în limba ta',
    'el' => 'Επεξήγηση στη γλώσσα σας',
    'ru' => 'Пояснение на вашем языке',
    'uk' => 'Пояснення вашою мовою',
    'ar' => 'شرح بلغتك',
    'fa' => 'توضیح به زبان شما',
    'he' => 'הסבר בשפה שלך',
    'hi' => 'आपकी भाषा में विवरण',
    'bn' => 'আপনার ভাষায় ব্যাখ্যা',
    'ur' => 'آپ کی زبان میں وضاحت',
    'id' => 'Penjelasan dalam bahasa Anda',
    'ms' => 'Penjelasan dalam bahasa anda',
    'fil' => 'Paliwanag sa iyong wika',
    'ko' => '현재 언어 설명',
    'ja' => '現在の言語での説明',
    'zh' => '当前语言说明',
    'vi' => 'Giải thích bằng ngôn ngữ của bạn',
    'th' => 'คำอธิบายในภาษาของคุณ',
    'sw' => 'Maelezo katika lugha yako',
    _ => 'Explanation in your language',
  };

  String get _turkishTitle => switch (_languageTag) {
    'tr' => 'Türkçe tam metin',
    'es' => 'Texto completo en turco',
    'pt-BR' || 'pt-PT' => 'Texto integral em turco',
    'fr' => 'Texte intégral en turc',
    'de' => 'Vollständiger türkischer Text',
    'it' => 'Testo completo in turco',
    'nl' => 'Volledige Turkse tekst',
    'pl' => 'Pełny tekst turecki',
    'ro' => 'Text integral în limba turcă',
    'el' => 'Πλήρες τουρκικό κείμενο',
    'ru' => 'Полный текст на турецком',
    'uk' => 'Повний текст турецькою',
    'ar' => 'النص التركي الكامل',
    'fa' => 'متن کامل ترکی',
    'he' => 'הנוסח המלא בטורקית',
    'hi' => 'पूरा तुर्की पाठ',
    'bn' => 'সম্পূর্ণ তুর্কি পাঠ',
    'ur' => 'مکمل ترکی متن',
    'id' => 'Teks lengkap bahasa Turki',
    'ms' => 'Teks penuh bahasa Turki',
    'fil' => 'Buong teksto sa Turko',
    'ko' => '터키어 전문',
    'ja' => 'トルコ語全文',
    'zh' => '土耳其语全文',
    'vi' => 'Toàn văn tiếng Thổ Nhĩ Kỳ',
    'th' => 'ข้อความภาษาตุรกีฉบับเต็ม',
    'sw' => 'Nakala kamili ya Kituruki',
    _ => 'Full Turkish text',
  };

  String get _englishTitle => switch (_languageTag) {
    'tr' => 'Bağlayıcı İngilizce tam metin',
    'es' => 'Texto completo vinculante en inglés',
    'pt-BR' => 'Texto integral vinculante em inglês',
    'pt-PT' => 'Texto integral vinculativo em inglês',
    'fr' => 'Texte anglais intégral faisant foi',
    'de' => 'Maßgeblicher englischer Volltext',
    'it' => 'Testo inglese completo prevalente',
    'nl' => 'Doorslaggevende volledige Engelse tekst',
    'pl' => 'Pełny wiążący tekst angielski',
    'ro' => 'Textul integral prevalent în engleză',
    'el' => 'Πλήρες δεσμευτικό αγγλικό κείμενο',
    'ru' => 'Полный приоритетный текст на английском',
    'uk' => 'Повний переважний текст англійською',
    'ar' => 'النص الإنجليزي الكامل المعتمد',
    'fa' => 'متن کامل انگلیسی حاکم',
    'he' => 'הנוסח האנגלי המלא והקובע',
    'hi' => 'पूरा प्रभावी अंग्रेज़ी पाठ',
    'bn' => 'সম্পূর্ণ প্রাধান্যপ্রাপ্ত ইংরেজি পাঠ',
    'ur' => 'مکمل حاکم انگریزی متن',
    'id' => 'Teks lengkap bahasa Inggris yang berlaku',
    'ms' => 'Teks penuh bahasa Inggeris yang mengikat',
    'fil' => 'Buong nangingibabaw na teksto sa Ingles',
    'ko' => '우선 적용되는 영어 전문',
    'ja' => '優先適用される英語全文',
    'zh' => '具有优先效力的英文全文',
    'vi' => 'Toàn văn tiếng Anh có hiệu lực ưu tiên',
    'th' => 'ข้อความภาษาอังกฤษฉบับเต็มที่มีผลเป็นหลัก',
    'sw' => 'Nakala kamili ya Kiingereza inayotawala',
    _ => 'English controlling full text',
  };

  @override
  Widget build(BuildContext context) {
    final document = MizanLegalDocuments.document(widget.type, _languageTag);
    final localized = ProBranding.visibleText(
      _languageTag,
      LegalLocaleSummaries.overview(widget.type, _languageTag),
    );
    final turkishMaster = LegalTurkishDocuments.forType(widget.type).trim();
    final englishMaster = document.englishMaster.trim();
    final canComplete = !widget.requireReadToEnd || _reachedEnd;

    return Scaffold(
      appBar: AppBar(title: Text(_localizedTitle)),
      body: Column(
        children: [
          Expanded(
            child: SelectionArea(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _localizedSectionTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Text(localized, style: const TextStyle(height: 1.55)),
                          const SizedBox(height: 12),
                          Text(
                            _consent('masterNotice'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _turkishTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 14),
                          Text(turkishMaster, style: const TextStyle(height: 1.55)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _englishTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 14),
                          Text(englishMaster, style: const TextStyle(height: 1.55)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.requireReadToEnd)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canComplete
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    icon: Icon(
                      canComplete
                          ? Icons.check_circle_outline
                          : Icons.lock_outline,
                    ),
                    label: Text(
                      canComplete ? _consent('readDone') : _consent('readAll'),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
