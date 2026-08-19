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
  static const String effectiveDate = '2026-08-19';
  static const String bundleVersion = '2026-08-19-r2';

  static const String _privacyEnglish = '''
PRIVACY POLICY — LEFFERION PRIME - MIZAN
Effective date: 19 August 2026

1. Scope and publisher. This Privacy Policy explains how LEFFERION PRIME - MIZAN (the “App”) handles information. The publisher and support contact are the developer identity and contact details displayed on the current Google Play listing. Those details must be kept accurate before public distribution.

2. Local financial records. People, debts, bills, subscriptions, rents, installments, expenses, income, payment history, notes, categories and related financial records are designed to remain on the user's device. The App does not require a publisher-operated user account, cloud ledger, financial-record database or synchronization server. The publisher does not receive the contents of those records during ordinary use.

3. Local technical state. The App stores settings and operational state locally, including language, region, currency preferences, legal-document acceptance version, Premium entitlement state, rewarded-ad progress, promotion redemption state and other settings needed for the requested functions. Local data can be lost if application storage is cleared, the device is reset, or the App is removed without a usable backup.

4. Connectivity checks. Free access requires a real internet connection. The App may make a small network reachability request to determine whether internet access is available. The user's financial ledger is not attached to that request. As with ordinary internet communication, the destination network service and network providers may process technical connection information such as IP address and request metadata.

5. Advertising and separate privacy choices. Free users may receive advertising through Google Mobile Ads. The App does not send the contents of the user's financial ledger to the advertising SDK for ad targeting. The Google Mobile Ads SDK may process device, app, advertising, diagnostic, network and interaction information according to Google's services, settings and applicable law. The App requests non-personalized advertising and sends Google's restricted data processing signal (`rdp=1`) on its ad requests as a conservative data-minimization measure. Non-personalized, limited, or restricted-data-processing advertising can still involve technical storage, access, measurement, fraud prevention, frequency control or other processing permitted by the applicable consent state, platform configuration and law.

Where advertising consent or an opt-out choice is required, the App uses Google User Messaging Platform (UMP) and the consent configuration published for the App. Advertising privacy consent is separate from acceptance of this Privacy Policy, the Terms of Use and the Purchase Terms. Refusing or withdrawing optional advertising consent does not by itself mean that the user has rejected those legal documents. The App asks the advertising SDK for ads only when the SDK reports that an ad request may be made. When required by the applicable UMP state, the App provides access to advertising privacy options so the user can revisit or withdraw choices.

6. Regional privacy rules. Privacy requirements differ by location. In the European Economic Area, the United Kingdom and Switzerland, regulated advertising consent and privacy choices are handled separately through the applicable UMP/CMP flow. In US states or other regions with applicable privacy, sale/share, targeted-advertising or similar rights, the App relies on the privacy messaging and ad-request controls configured for the advertising services where applicable. Mandatory local rights remain available regardless of this Policy.

7. Google Play purchases and restore. Lifetime Premium is a one-time Google Play in-app product. After the legal bundle has been accepted, the App can use Google Play's on-device billing APIs and purchase ownership/history information to load the product, begin a purchase, acknowledge a completed purchase and silently restore ownership. The App does not operate its own purchase-verification server and does not send the raw purchase token to a publisher-operated backend. Payment-card information is processed by Google Play, not by the App.

8. Promotion codes. Promotion matching is performed locally inside the App. Supported code values are represented by cryptographic fingerprints rather than ordinary readable code strings in the validator. Successful redemption state is stored locally and is not sent to a publisher-operated promotion server. Because the mechanism is local, uninstalling the App, clearing data, factory-resetting a device or some backup/restore operations can affect local redemption history.

9. Rewarded advertising. A free user may deliberately start an eligible rewarded ad. Google Mobile Ads supplies the ad and reports whether the reward condition was completed. The App records reward progress locally. Three successfully completed rewarded ads in the applicable reward day grant 24 hours of temporary Premium. The publisher does not operate a separate rewarded-ad verification server.

10. Exports and sharing. CSV backup export/import is available only to a verified permanent Google Play Premium purchase; temporary Premium does not unlock backup. A permanent-Premium CSV backup may contain a one-way fingerprint derived from purchase proof, but that fingerprint does not independently grant Premium. PDF reports are created only when requested. If the user saves or shares an exported file through another app, storage provider or communication service, that destination processes the file under its own terms. Exported files may contain sensitive financial information and should be protected accordingly.

11. Purposes and third parties. Processing is limited to providing requested App functions, local persistence, connectivity checking, advertising and required privacy choices, Google Play purchases and restore, local promotion/reward handling, diagnostics inherent in third-party SDKs, and user-requested exports. Relevant third parties can include Google Play, Google Mobile Ads, Google User Messaging Platform, the user's network provider, a reachability destination, and any service the user selects for export or sharing. Those third parties operate under their own privacy terms and may process data in countries permitted by their legal frameworks and service configurations.

12. Retention. Core financial records remain locally until the user deletes them, clears App storage, removes the App without restoring a backup, or otherwise removes them. Local Premium, promotion, rewarded-progress and acceptance state remains only as needed for App operation and can be lost when local application data is removed. Advertising, consent and Google-controlled data follow the applicable Google configuration, retention rules and legal requirements.

13. Security. The App uses local-storage validation, platform purchase APIs and cryptographic comparison for embedded promotion validation. No device, network or software system can be guaranteed absolutely secure. Users should protect their device, Google account, screen lock and exported files.

14. Rights and choices. Depending on location, users may have rights of access, deletion, correction, objection, restriction, withdrawal of consent, opt-out or complaint. Advertising privacy choices are made available through the applicable privacy flow when required. Since the publisher does not operate a server containing the user's financial ledger, actions concerning those locally stored records normally need to be performed on the user's device or backup. Requests concerning Google-controlled payment, advertising or consent data may need to be directed to Google. Nothing in this Policy limits mandatory statutory rights.

15. Children. The App is a personal financial-tracking utility and is not designed or marketed as a child-directed service. A person who cannot legally enter the applicable agreements must use the App only with any authorization or supervision required by local law.

16. Changes and language. This Policy may be updated when functionality, providers or law changes. A new material legal-bundle version requires renewed in-App acceptance before normal App use and purchasing. Localized explanations are provided for accessibility. The English text is the controlling reference to the maximum extent permitted by law without reducing mandatory local rights.
''';

  static const String _termsEnglish = '''
TERMS OF USE — LEFFERION PRIME - MIZAN
Effective date: 19 August 2026

1. Agreement and access gate. After the initial language/region/currency setup needed to present the correct interface, the App requires the current Privacy Policy, Terms of Use and Purchase Terms to be opened through the required read flow and accepted before normal App functionality or purchasing is enabled. If the legal bundle is materially revised, the new version must be accepted again. Advertising privacy consent, where legally required, is a separate choice and is not bundled into this contractual acceptance.

2. Eligibility. A user must have legal capacity to accept these Terms or any parental, guardian or other authorization required by local law. Mandatory consumer and privacy rights that cannot legally be excluded remain unaffected.

3. Purpose. MIZAN is a personal record-keeping utility for debts, bills, subscriptions, rents, installments, expenses, income, payments and related records. It does not provide banking, investment, tax, accounting, legal, credit, debt-collection or other regulated professional advice. Users remain responsible for verifying important amounts, dates, interest, fees, taxes and contractual obligations with the relevant institution or qualified professional.

4. Free and Premium access. Free access requires internet connectivity, can display advertising and does not include real PDF report export. Valid Premium removes App-served advertising, permits offline use and enables PDF report export. Temporary Premium may be granted through eligible rewarded advertising or local promotion codes and expires automatically. Lifetime Premium is a separate one-time Google Play entitlement with no recurring subscription charge and no preset time-based expiry while valid ownership remains recognized.

5. Advertising. Free users may receive App-served advertising, including full-screen advertising at appropriate points and user-initiated rewarded advertising. The App does not promise a particular number, timing, behavioral threshold or frequency of advertisements in these Terms. Advertising inventory and delivery are not guaranteed. Where law requires advertising consent or privacy choices, those choices are handled separately through the applicable consent/privacy flow. Premium users should not receive App-served advertising while Premium is active.

6. Local data and backup. The App is intentionally serverless for the user's financial ledger. The publisher does not provide a cloud ledger or guaranteed remote backup. CSV backup export/import is a permanent Google Play Premium benefit and is not unlocked by temporary rewarded or promotion Premium. A backup purchase fingerprint is supporting provenance only and cannot independently create an entitlement. Users are responsible for the accuracy of their records and for protecting backups. Device failure, operating-system behavior, deletion, factory reset, storage corruption or uninstall without a usable backup can cause data loss.

7. Purchases and restore. Lifetime Premium is purchased through Google Play only after the current legal bundle has been accepted. The App can silently check Google Play ownership when the store is reachable and can restore the one-time product on a compatible installation using the owning Google account. There is no publisher-operated billing backend. A fresh installation without a local entitlement cache needs Google Play connectivity before ownership can be restored.

8. Promotions. Promotion validation occurs locally using cryptographic fingerprints rather than a publisher-operated promotion service. Redemption state is local. Users may not modify the App, local storage or executable package to forge a promotion result or Premium entitlement. A local-only mechanism cannot guarantee permanent physical-device recognition across every uninstall, data wipe, factory reset, backup restore or platform identity change.

9. Rewarded Premium. A free online user may deliberately complete eligible rewarded ads. Three successfully completed rewarded ads in the applicable reward day grant 24 hours of temporary Premium. An ad counts only after the advertising provider reports the reward callback. Reward availability is not guaranteed, has no cash value and is non-transferable.

10. Acceptable use. Users may not intentionally bypass Premium controls, Google Play ownership, promotion limits, advertising or privacy controls; forge entitlement state; distribute modified builds that misrepresent access; introduce malware; interfere with another person's device or data; or use the App unlawfully.

11. Availability and changes. The publisher may maintain, secure, fix, improve or change the App, supported operating-system versions, advertising providers and non-essential features. Reasonable efforts should be made not to remove a paid core entitlement without legitimate cause. Google Play, advertising inventory, network connectivity and other third-party services can be unavailable outside the publisher's control.

12. Intellectual property. Subject to these Terms, the user receives a limited, personal, non-exclusive and non-transferable license to use the App lawfully. Software, branding, original interface assets and protected materials remain with their respective rights holders.

13. Disclaimer and liability. To the maximum extent permitted by applicable law, the App does not guarantee that every calculation, export, network check, local record or third-party service will always be uninterrupted or error-free. Users should independently verify important financial obligations. Nothing excludes liability, remedies or warranties that applicable law does not permit to be excluded.

14. Refunds and disputes. Refunds and purchase reversals are governed by Google Play rules and applicable consumer law. If Google Play no longer reports ownership after a refund, cancellation, reversal or revocation, permanent Premium may cease after a reliable ownership synchronization. Financial records are not deleted merely because Premium ends. Mandatory consumer forums, remedies and protections remain available.

15. Termination and refusal. A user who does not accept the current mandatory legal bundle cannot proceed to normal App functionality or purchasing. The separate refusal or withdrawal of optional advertising consent is handled according to the applicable advertising privacy flow and does not by itself cancel acceptance of these Terms.

16. Language and severability. Localized explanations are provided for accessibility. The English text is the controlling reference to the maximum extent permitted by law. If a clause is unenforceable, it is limited or separated only as necessary while the remaining clauses continue to apply.
''';

  static const String _purchaseEnglish = '''
PURCHASE TERMS — LIFETIME AND TEMPORARY PREMIUM
Effective date: 19 August 2026

1. Acceptance before purchase. A Google Play purchase cannot be initiated from the App until the current mandatory legal bundle has been accepted. The Purchase Terms are included in that bundle and can also be opened again from the Premium screen. Advertising privacy consent is a separate matter and is not a condition for accepting these Purchase Terms.

2. Lifetime Premium product. Lifetime Premium is offered through Google Play as the one-time, non-consumable product “premium_lifetime”. It is not a subscription, does not renew automatically and has no recurring subscription fee. The price and currency returned by Google Play and displayed for the transaction are the applicable store price, including regional pricing and taxes as determined by Google Play.

3. Lifetime Premium benefits. While valid, Lifetime Premium provides an ad-free App experience, offline App use, PDF report export and permanent-Premium CSV backup functionality described in the App. “Lifetime” means the entitlement has no preset time-based expiry; it does not promise that a particular device, operating system, Google Play service or third-party infrastructure will exist forever.

4. Automatic restore. The App intentionally does not require a visible restore button. After the legal bundle has been accepted and Google Play is reachable, the App listens for purchase updates and silently checks Google Play ownership. After reinstalling the App or moving to another compatible device, the one-time product can be restored automatically when Google Play reports the same valid ownership, normally through the Google account that owns the purchase.

5. Serverless ownership flow. The App does not operate a publisher-owned billing-verification backend. Purchase initiation, purchase state and historical ownership are obtained through Google Play billing APIs on the device. Completed purchases are acknowledged through the store integration when required. A previously cached local entitlement can permit offline Premium use, but a fresh install with no local entitlement cache requires Google Play connectivity before ownership can be restored.

6. Refunds and mandatory rights. Refund eligibility is governed by Google Play rules, applicable consumer law and any additional publisher obligations. Nothing in these Terms removes a statutory cancellation, conformity, refund or other remedy that cannot lawfully be waived. If Google Play stops reporting ownership because of a refund, cancellation, reversal or revocation, the App may remove permanent Premium after a successful ownership synchronization. User financial records are not deleted for that reason.

7. Rewarded temporary Premium. A free online user may be offered rewarded advertising. Three completed eligible rewarded ads in the applicable reward day grant 24 hours of temporary Premium. An ad counts only after the advertising provider reports the reward callback. Closing, failing or abandoning an ad before that point does not increment progress. Reward availability is not guaranteed, has no cash value and cannot be transferred.

8. Promotion codes. Supported promotion codes are embedded through cryptographic fingerprints rather than ordinary readable code strings in the validator. A successful code can grant a defined temporary Premium period and redemption state is stored locally. There is no publisher-operated promotion server, D1 database or remote promotion secret. Local storage can be cleared by uninstall, data wipe, factory reset or some backup/restore operations, so local-only redemption controls cannot guarantee immutable one-use enforcement across every reset scenario. Users may not manipulate the App or storage to forge redemption or entitlement state.

9. Temporary entitlement interaction. Temporary Premium granted by an eligible promotion or rewarded-ad completion is applied using the App's local entitlement logic. An additional valid temporary duration may extend an already active temporary entitlement according to the App's current rules. Temporary Premium does not become a cash balance, a transferable credit or a recurring subscription.

10. Price changes and future promotions. The publisher may change future Google Play pricing or introduce, modify or end promotion campaigns subject to platform rules and applicable law. A later price change does not create a recurring charge and does not retroactively change a completed one-time purchase.

11. Purchase support. For purchase or restore issues, users should confirm that Google Play is available and the device is using the Google account that owns the purchase. Support can be requested through the developer contact shown on the Google Play listing. Refund requests may need to be submitted through Google Play under the rules applicable to the transaction and country.

12. Security limitations. Because the App intentionally avoids a publisher-operated entitlement server, permanent purchase restore relies on Google Play and temporary promotion/reward state relies on local application storage. Local temporary entitlement records are not a transferable account balance or guaranteed cloud backup.

13. Language. Localized explanations are provided for accessibility. The English text is the controlling reference to the maximum extent permitted by law without reducing mandatory local consumer rights.
''';

  static String _overview(LegalDocumentType type, String languageTag) {
    if (languageTag == 'tr') {
      return switch (type) {
        LegalDocumentType.privacy =>
          'Finansal kayıtlar cihazda yerel tutulur. Reklam gizlilik tercihleri gerektiğinde Google UMP üzerinden ve sözleşme kabulünden ayrı yönetilir. Uygulama reklam SDK’sına finansal kayıt defterini hedefleme amacıyla göndermez.',
        LegalDocumentType.terms =>
          'Normal uygulama kullanımı ve satın alma başlamadan önce güncel hukuki paket kabul edilmelidir. Ücretsiz kullanım internet ve reklam içerebilir; Premium reklamsız çevrimdışı kullanım ve PDF sağlar.',
        LegalDocumentType.purchase =>
          'Ömür boyu Premium Google Play üzerindeki tek seferlik premium_lifetime ürünüdür. Satın alma ancak güncel hukuki paket kabul edildikten sonra başlatılabilir ve sahiplik Google Play üzerinden sessizce geri yüklenebilir.',
      };
    }
    return switch (type) {
      LegalDocumentType.privacy =>
        'Financial records remain local. Where required, advertising privacy choices are handled through Google UMP separately from mandatory legal acceptance. The App does not send the financial ledger to the advertising SDK for targeting.',
      LegalDocumentType.terms =>
        'The current legal bundle must be accepted before normal App use or purchasing. Free access can include internet and advertising; Premium provides ad-free offline use and PDF export.',
      LegalDocumentType.purchase =>
        'Lifetime Premium is the one-time premium_lifetime Google Play product. A purchase can start only after the current legal bundle is accepted, and valid ownership can be silently restored through Google Play.',
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
