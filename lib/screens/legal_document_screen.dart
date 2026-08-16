import 'package:flutter/material.dart';

import '../l10n/mizan_i18n.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_locale_summaries.dart';
import '../monetization/pro_branding.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({required this.type, super.key});

  final LegalDocumentType type;

  String get _localizedTitle => switch (type) {
    LegalDocumentType.privacy => switch (MizanI18n.languageTag) {
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
    LegalDocumentType.terms => switch (MizanI18n.languageTag) {
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
    LegalDocumentType.purchase => switch (MizanI18n.languageTag) {
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

  String get _localizedSectionTitle => switch (MizanI18n.languageTag) {
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

  String get _controllingTextTitle => switch (MizanI18n.languageTag) {
    'tr' => 'Bağlayıcı İngilizce metin',
    'es' => 'Texto inglés vinculante',
    'pt-BR' => 'Texto vinculante em inglês',
    'pt-PT' => 'Texto vinculativo em inglês',
    'fr' => 'Texte anglais faisant foi',
    'de' => 'Maßgeblicher englischer Text',
    'it' => 'Testo inglese prevalente',
    'nl' => 'Doorslaggevende Engelse tekst',
    'pl' => 'Wiążący tekst angielski',
    'ro' => 'Textul englez prevalent',
    'el' => 'Δεσμευτικό αγγλικό κείμενο',
    'ru' => 'Приоритетный текст на английском языке',
    'uk' => 'Переважний текст англійською мовою',
    'ar' => 'النص الإنجليزي المعتمد',
    'fa' => 'متن انگلیسی حاکم',
    'he' => 'הנוסח האנגלי הקובע',
    'hi' => 'प्रभावी अंग्रेज़ी पाठ',
    'bn' => 'প্রাধান্যপ্রাপ্ত ইংরেজি পাঠ',
    'ur' => 'حاکم انگریزی متن',
    'id' => 'Teks bahasa Inggris yang berlaku',
    'ms' => 'Teks bahasa Inggeris yang mengikat',
    'fil' => 'Nangingibabaw na tekstong Ingles',
    'ko' => '우선 적용되는 영어 원문',
    'ja' => '優先適用される英語原文',
    'zh' => '具有优先效力的英文文本',
    'vi' => 'Văn bản tiếng Anh có hiệu lực ưu tiên',
    'th' => 'ข้อความภาษาอังกฤษที่มีผลบังคับใช้เป็นหลัก',
    'sw' => 'Nakala ya Kiingereza inayotawala',
    _ => 'English controlling text',
  };

  String get _effectiveDateLabel => switch (MizanI18n.languageTag) {
    'tr' => 'Yürürlük tarihi',
    'es' => 'Fecha de entrada en vigor',
    'pt-BR' => 'Data de vigência',
    'pt-PT' => 'Data de entrada em vigor',
    'fr' => 'Date d’entrée en vigueur',
    'de' => 'Gültig ab',
    'it' => 'Data di entrata in vigore',
    'nl' => 'Ingangsdatum',
    'pl' => 'Data wejścia w życie',
    'ro' => 'Data intrării în vigoare',
    'el' => 'Ημερομηνία έναρξης ισχύος',
    'ru' => 'Дата вступления в силу',
    'uk' => 'Дата набрання чинності',
    'ar' => 'تاريخ السريان',
    'fa' => 'تاریخ اجرا',
    'he' => 'תאריך תחילה',
    'hi' => 'प्रभावी तिथि',
    'bn' => 'কার্যকর তারিখ',
    'ur' => 'تاریخ نفاذ',
    'id' => 'Tanggal berlaku',
    'ms' => 'Tarikh berkuat kuasa',
    'fil' => 'Petsa ng bisa',
    'ko' => '시행일',
    'ja' => '発効日',
    'zh' => '生效日期',
    'vi' => 'Ngày có hiệu lực',
    'th' => 'วันที่มีผลใช้บังคับ',
    'sw' => 'Tarehe ya kuanza kutumika',
    _ => 'Effective date',
  };

  @override
  Widget build(BuildContext context) {
    final languageTag = MizanI18n.languageTag;
    final document = MizanLegalDocuments.document(type, languageTag);
    final localized = ProBranding.visibleText(
      languageTag,
      LegalLocaleSummaries.overview(type, languageTag),
    );
    final englishMaster = ProBranding.visibleText(
      'en',
      document.englishMaster.trim(),
    );
    return Scaffold(
      appBar: AppBar(title: Text(_localizedTitle)),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedSectionTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(localized, style: const TextStyle(height: 1.55)),
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
                      _controllingTextTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_effectiveDateLabel: ${MizanLegalDocuments.effectiveDate}',
                      style: Theme.of(context).textTheme.bodySmall,
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
    );
  }
}
