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
                      'English controlling text',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Effective date: ${MizanLegalDocuments.effectiveDate}',
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
