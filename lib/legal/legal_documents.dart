enum LegalDocumentType { privacy, terms, purchase }

class LegalDocument {
  const LegalDocument({
    required this.type,
    required this.title,
    required this.localizedOverview,
    required this.englishMaster,
  });

  final LegalDocumentType type;
  final String title;
  final String localizedOverview;
  final String englishMaster;
}

abstract final class MizanLegalDocuments {
  static const String effectiveDate = '2026-08-18';

  static const String _privacyEnglish = '''
PRIVACY POLICY — LEFFERION PRIME - MIZAN
Effective date: 18 August 2026

1. Scope. This Privacy Policy explains how the LEFFERION PRIME - MIZAN application handles information. The publisher and support contact are the developer identity and contact details shown on the current Google Play listing. Those details must be accurate before public distribution.

2. Local financial records. People, debts, bills, subscriptions, rents, installments, expenses, income, payment history, notes, categories and related financial records are designed to remain on the user's device. The App does not require a publisher-operated account, database, cloud backend or synchronization server for those records. The publisher does not receive the contents of those records during ordinary use.

3. Exports and sharing. CSV backups and PDF reports are created only when the user requests them. If the user saves or shares an exported file through another application, storage provider or communication service, that destination handles the file under its own privacy terms. Exported files can contain sensitive financial information and should be protected appropriately.

4. Free-mode connectivity and advertising. The free version requires real internet access and may make a small reachability request only to determine whether the device is online. The financial ledger is not included in that reachability request. Free users may receive advertising through Google Mobile Ads. Where required by law, Google User Messaging Platform or another required consent flow is used before regulated advertising requests, and privacy options are made available when required.

5. Google Play purchases. Lifetime PRO is a one-time Google Play in-app product. The App uses Google Play's on-device billing APIs and purchase history/ownership information to start purchases, acknowledge completed purchases and silently restore ownership when Google Play reports that the current account owns the product. The App does not operate its own purchase-verification server and does not send purchase tokens to a publisher-operated backend. Payment-card information is processed by Google Play, not by the App.

6. Promotion codes. Promotion-code matching is performed locally inside the App. The supported code values are not stored as ordinary visible text in the promotion validator; the App compares cryptographic fingerprints and records successful local redemption state on the device. Promotion redemption is not transmitted to a publisher-operated promotion server. Because this state is local, clearing application storage, uninstalling the App, restoring a device backup or changing device state may affect whether the App can remember a previous local redemption. The App must not claim that a local-only mechanism can provide an immutable cross-reset physical-device identity.

7. Rewarded advertising. When a free user deliberately watches an eligible rewarded ad, Google Mobile Ads supplies the ad and reports completion to the App. The App records reward progress locally. Three completed rewarded ads in the applicable reward day grant 24 hours of temporary PRO. The publisher does not operate a separate rewarded-ad session server.

8. Purposes and providers. Processing is limited to providing requested App functions, checking connectivity for free access, presenting advertising, obtaining legally required advertising consent, performing Google Play purchases and restore, and creating user-requested exports. Relevant third-party providers can include Google Play, Google Mobile Ads, Google User Messaging Platform, the user's network provider and any destination selected for export or sharing. Their own terms and privacy notices also apply.

9. Retention. Core financial records remain locally until the user deletes them, clears App storage, removes the App without restoring a backup, or otherwise removes them. Local PRO, promotion and rewarded-progress state is retained only on the device as needed for App operation and can be lost when local application data is removed. Advertising and consent data follows the applicable Google configuration and legal requirements.

10. Security. The App uses local-storage validation, platform purchase APIs and cryptographic comparison for embedded promotion validation. No device or software system can be guaranteed absolutely secure. Users should protect their device, Google account, screen lock and exported files.

11. Rights and choices. Depending on location, users may have privacy and consumer rights. Advertising privacy choices are available when required. Since the publisher does not operate a server containing the user's financial ledger, requests concerning locally stored financial records generally require action on the user's own device or exported backups. Requests concerning Google-controlled payment or advertising data may need to be directed to Google.

12. Children. The App is a personal financial-tracking utility and is not designed or marketed as a child-directed service. Users who cannot legally enter the relevant agreements should use it only with any consent or supervision required by local law.

13. Changes. This Policy may be updated when App functionality, providers or law changes. Material changes should be presented through a reasonable notice method where required.

14. Language. Localized explanations are provided for accessibility. The English text is the controlling reference to the maximum extent permitted by law without reducing mandatory local rights.
''';

  static const String _termsEnglish = '''
TERMS OF USE — LEFFERION PRIME - MIZAN
Effective date: 18 August 2026

1. Agreement and eligibility. By using the App, the user agrees to these Terms and the Privacy Policy. Any parental, guardian or other authorization required by local law must be obtained before use. Mandatory rights that cannot legally be excluded remain unaffected.

2. Purpose. MIZAN is a personal record-keeping and reminder utility for debts, bills, subscriptions, rents, installments, expenses, income, payments and related records. It does not provide banking, investment, tax, accounting, legal, credit, debt-collection or other regulated professional advice. Users remain responsible for verifying amounts, due dates, interest, fees, taxes and contractual obligations with the relevant institution or qualified professional.

3. Free and PRO access. Free access requires internet connectivity, may display advertising and does not include real PDF report export. Valid PRO removes App-served advertising, permits offline use and enables PDF report export. Temporary PRO may be granted through eligible rewarded advertising or local promotion codes and expires automatically. Lifetime PRO is a separate one-time Google Play entitlement with no recurring subscription charge and no preset time-based expiry while Google Play ownership remains valid.

4. Advertising. Free users may see interstitial advertising at intended transition points subject to the App's cooldown and behavior rules. Rewarded advertising is started deliberately by the user. Advertising inventory is not guaranteed. PRO users should not receive App-served advertising while PRO remains active.

5. Local data and backups. The App is intentionally serverless for user financial records. The publisher does not provide a cloud ledger or guaranteed remote backup. Users are responsible for the accuracy of records and for creating and protecting CSV backups appropriate to the importance of their data. Local data can be lost through device failure, operating-system behavior, user deletion, factory reset, storage corruption or uninstall without a usable backup.

6. Purchases and restore. Lifetime PRO is purchased through Google Play. The App silently checks Google Play purchase history/ownership when the store is reachable and may restore the one-time product on a compatible installation using the Google account that owns it. There is no publisher-operated billing backend. A fresh reinstall cannot recover a deleted local entitlement while completely offline; Google Play must first be reachable to report ownership.

7. Promotions. Promotion validation occurs locally in the App using cryptographic fingerprints rather than a publisher-operated promotion service. Local redemption state is stored on the device. Users may not intentionally modify the App, local storage or executable code to forge a promotion result or PRO entitlement. A local-only mechanism cannot guarantee permanent recognition of a physical device after every uninstall, data wipe, factory reset, backup restore or platform identity change, and the App does not promise otherwise.

8. Rewarded PRO. A free online user may complete eligible rewarded ads. Three completed rewarded ads in the applicable reward day grant 24 hours of temporary PRO. Closing or failing an ad before the provider reward callback does not count. Reward inventory has no cash value, is non-transferable and may be unavailable.

9. Acceptable use. Users may not intentionally bypass PRO controls, advertising gates, Google Play purchase ownership, promotion limits or other security controls; forge entitlement state; distribute modified builds that misrepresent access; introduce malware; interfere with another user's device or data; or use the App unlawfully.

10. Availability and changes. The publisher may maintain, fix, improve or change the App, supported operating-system versions, advertising providers and non-essential features. Reasonable efforts should be made not to remove a paid core entitlement without legitimate cause. Google Play, advertising inventory, internet connectivity and other third-party services can be unavailable outside the publisher's control.

11. Intellectual property. Subject to these Terms, the user receives a limited, personal, non-exclusive and non-transferable license to use the App lawfully. The software, branding, original interface assets and protected materials remain with their respective rights holders.

12. Disclaimer and liability. To the maximum extent allowed by applicable law, the App is provided without a guarantee that every reminder, calculation, export, network check or third-party service will always be uninterrupted or error-free. Users should independently verify important financial obligations. Nothing excludes liability or remedies that applicable law does not permit to be excluded.

13. Refunds and disputes. Refunds and purchase reversals are governed by Google Play rules and applicable consumer law. If Google Play no longer reports ownership after a refund, cancellation or revocation, PRO may cease after reliable ownership synchronization. Financial records are not deleted merely because PRO ends. Mandatory consumer forums, remedies and protections remain available.

14. Language and severability. Localized explanations are provided for accessibility. The English text is the controlling reference to the maximum extent permitted by law. If a clause is unenforceable, it is limited or separated only as necessary while the remaining clauses continue to apply.
''';

  static const String _purchaseEnglish = '''
PURCHASE TERMS — LIFETIME AND TEMPORARY PRO
Effective date: 18 August 2026

1. Lifetime PRO product. Lifetime PRO is offered through Google Play as the one-time, non-consumable product “premium_lifetime”. It is not a subscription, does not renew automatically and has no recurring subscription fee. The price and currency displayed by Google Play at checkout are the binding store price for that transaction, including applicable regional pricing and taxes.

2. Lifetime PRO benefits. While valid, Lifetime PRO provides an ad-free App experience, offline App use and PDF report export. “Lifetime” means the entitlement has no preset time-based expiry. It does not promise that a particular device, operating system, Google Play service or third-party infrastructure will exist forever.

3. Automatic restore. The App intentionally does not require a visible restore button. On supported Android installations, the App listens for purchase updates and silently checks Google Play ownership when the store can be reached. After reinstalling the App or moving to another compatible device, the one-time product can be restored automatically when Google Play reports the same valid ownership, normally through the Google account that owns the purchase.

4. Serverless ownership flow. The App does not operate a publisher-owned billing verification backend. Purchase initiation, purchase state and historical ownership are obtained through Google Play billing APIs on the device. A completed purchase is acknowledged through the store integration when required. A previously cached local entitlement can continue to permit offline PRO use, but a fresh reinstall with no local entitlement cache requires Google Play connectivity before ownership can be restored.

5. Refunds and mandatory rights. Refund eligibility is governed by Google Play rules, applicable consumer law and any additional publisher obligations. Nothing in these Terms removes a statutory cancellation, conformity, refund or other remedy that cannot lawfully be waived. If Google Play later stops reporting ownership because of a refund, cancellation, reversal or revocation, the App may remove the permanent PRO entitlement after a successful ownership synchronization. User financial records are not deleted for that reason.

6. Rewarded temporary PRO. A free online user may be offered rewarded advertising. Three completed eligible rewarded ads in the applicable reward day grant 24 hours of temporary PRO. An ad counts only after the advertising provider reports the reward callback. Closing, failing or abandoning an ad before that point does not increment progress. Reward availability is not guaranteed, has no cash value and cannot be transferred.

7. Promotion codes. Supported promotion codes are embedded in the App through cryptographic fingerprints rather than stored as ordinary visible code strings inside the validator. A successful code can grant a defined temporary PRO period, and successful redemption state is stored locally on the device. There is no publisher-operated promotion server, D1 database or remote promotion secret. Local storage can be cleared by uninstall, data wipe, factory reset or some backup/restore operations, so local-only redemption controls cannot guarantee immutable one-use enforcement across every device reset scenario. Users may not manipulate the App or storage to forge redemption or entitlement state.

8. Temporary entitlement interaction. Temporary PRO granted by a valid promotion or rewarded-ad completion is applied using the App's local entitlement clock logic. When a temporary entitlement is already active, an additional valid temporary duration may extend the existing end time according to the App's current rules. Temporary PRO does not convert into a cash refund or recurring subscription.

9. Price changes and future promotions. The publisher may change future Google Play pricing or introduce, modify or end promotion campaigns subject to platform rules and applicable law. A later price change does not create a recurring charge and does not retroactively alter a completed one-time purchase.

10. Purchase support. For purchase or restore issues, users should first confirm that Google Play is available and that the device is using the Google account that owns the purchase. Support can be requested through the developer contact shown on the Google Play listing. Refund requests may need to be submitted through Google Play according to the rules applicable to the user's transaction and country.

11. Security limitations. Because the App intentionally avoids a publisher-operated entitlement server, purchase restore relies on Google Play and temporary promotion/reward state relies on local application storage. Users must not treat local temporary entitlement records as a transferable account balance or guaranteed cloud backup.

12. Language. Localized explanations are provided for accessibility. The English text is the controlling reference to the maximum extent permitted by law without reducing mandatory local consumer rights.
''';

  static String _overview(LegalDocumentType type, String languageTag) {
    if (languageTag == 'tr') {
      return switch (type) {
        LegalDocumentType.privacy =>
          'Finansal kayıtlar cihazda yerel tutulur. Uygulamanın kullanıcı kayıtları, promosyonlar veya PRO hakkı için yayıncıya ait bir sunucu ya da bulut veritabanı yoktur. Google Play satın alma ve otomatik geri yükleme işlemleri mağazanın cihaz tarafındaki sahiplik bilgisiyle, promosyonlar ise uygulama içindeki kriptografik eşleştirme ve yerel durumla çalışır.',
        LegalDocumentType.terms =>
          'MIZAN yerel çalışan kişisel finans takip aracıdır. Ücretsiz kullanım internet ve reklam gerektirir; PRO çevrimdışı kullanım, reklamsız deneyim ve PDF sağlar. Satın alma sahipliği Google Play üzerinden otomatik kontrol edilir; promosyon ve ödüllü reklam hakları yerel olarak uygulanır.',
        LegalDocumentType.purchase =>
          'Ömür boyu PRO Google Play üzerinde tek seferlik premium_lifetime ürünüdür ve otomatik geri yükleme Google Play satın alma geçmişiyle yapılır. Üç ödüllü reklam 24 saat PRO sağlar. Promosyon doğrulaması uygulamanın içinde kriptografik olarak yapılır; yayıncıya ait promosyon veya satın alma sunucusu kullanılmaz.',
      };
    }
    return switch (type) {
      LegalDocumentType.privacy =>
        'Financial records stay on the device. The App does not use a publisher-operated server or cloud database for user records, promotion validation or PRO entitlement. Google Play purchases and silent restore use store ownership information, while promotion matching and temporary entitlement state are local to the App.',
      LegalDocumentType.terms =>
        'MIZAN is a local personal finance tracker. Free access requires internet and advertising; PRO provides offline use, an ad-free experience and PDF export. Google Play ownership is checked automatically, while promotion and rewarded-ad temporary entitlements are handled locally.',
      LegalDocumentType.purchase =>
        'Lifetime PRO is the one-time premium_lifetime Google Play product and silent restore uses Google Play purchase ownership. Three rewarded ads grant 24 hours of PRO. Promotion validation is embedded cryptographically inside the App and does not require a publisher-operated purchase or promotion server.',
    };
  }

  static LegalDocument document(LegalDocumentType type, String languageTag) {
    return switch (type) {
      LegalDocumentType.privacy => LegalDocument(
        type: type,
        title: 'Privacy Policy',
        localizedOverview: _overview(type, languageTag),
        englishMaster: _privacyEnglish,
      ),
      LegalDocumentType.terms => LegalDocument(
        type: type,
        title: 'Terms of Use',
        localizedOverview: _overview(type, languageTag),
        englishMaster: _termsEnglish,
      ),
      LegalDocumentType.purchase => LegalDocument(
        type: type,
        title: 'Purchase Terms',
        localizedOverview: _overview(type, languageTag),
        englishMaster: _purchaseEnglish,
      ),
    };
  }
}
