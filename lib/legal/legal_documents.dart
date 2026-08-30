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
  static const String generalBundleVersion = '2026-08-30-general-r2';
  static const String purchaseTermsVersion = '2026-08-30-purchase-r2';
  static const String bundleVersion = generalBundleVersion;

  static const String _privacyEnglish = '''
PRIVACY POLICY — LEFFERION PRIME - MIZAN

1. Data stored on the device

MIZAN is a personal finance tracking application designed so that the user's core financial records remain on the user's own device wherever possible.

People, debts, bills, subscriptions, rents and installments, expenses, income, payment records, notes, categories and related information are stored locally on the device.

MIZAN does not require a publisher-operated user account, cloud ledger or financial-record server to store those records. During ordinary App use, the contents of the user's financial records are not sent to the publisher.

2. App settings

Settings needed for the App to operate, including language, country or region, currency preferences, legal-document acknowledgement and acceptance state, PRO access state and similar operational settings, may be stored on the device.

Removing the App, clearing App data, resetting the device or otherwise losing device data may cause locally stored information to be lost.

MIZAN does not promise an automatic publisher-operated cloud backup for the user's financial records.

3. Internet connectivity

Free access requires an active internet connection. The App may check whether internet access is available in order to determine whether the free-access condition is satisfied.

When PRO access is active, the App's core local features may be used offline.

The contents of the user's MIZAN financial records are not attached to the connectivity check.

4. Advertising services and privacy choices

Third-party advertising services such as Google Mobile Ads may be used during free access.

MIZAN does not send the contents of debts, bills, income, expenses or other financial records entered into the App to advertising services for ad targeting.

Advertising services may process device, App, advertising-interaction and similar information under their own privacy policies and applicable rules.

Where a separate advertising consent or privacy choice is required, the relevant Google privacy or consent mechanisms may be used. Advertising privacy choices are separate from acknowledging this Privacy Policy and accepting the Terms of Use.

5. Purchases through Google Play

Permanent PRO purchases are carried out through Google Play.

Google Play conducts the payment transaction and processes payment information. MIZAN does not directly receive or store the user's payment-card information on a publisher-operated server.

Valid purchase and ownership information provided through Google Play may be used so that PRO access can be applied to the App.

6. PDF and CSV files

PDF reports and CSV backups created at the user's request may contain the user's financial records.

If a user saves or shares one of these files through another application, storage provider or communication service, the selected third-party service processes the file under its own terms and privacy practices.

The user is responsible for protecting exported financial files appropriately.

7. Retention and deletion

Local financial records may remain on the device until the user deletes them, clears App data or the App data is otherwise removed from the device.

Because MIZAN does not operate an account system that stores the user's financial ledger on a publisher server, actions involving those local records are normally performed on the user's device or on a backup controlled by the user.

8. Security

MIZAN uses appropriate application and platform controls to protect local data and PRO access state.

No device, software or storage method can provide an absolute security guarantee.

Users should protect their device, Google account, screen lock and exported files appropriately.

9. User rights and choices

Depending on the user's country or region, applicable law may provide rights concerning personal data, including access, deletion, correction, objection, restriction, withdrawal of consent or similar rights.

Some choices and requests concerning information processed by third-party advertising or Google services may need to be exercised through the tools provided by the relevant service provider.

This Policy does not limit rights that applicable law does not permit the user to waive.

10. Use by children

MIZAN is designed for personal finance tracking and is not designed as a child-directed service.

A person who does not have legal capacity to accept the relevant agreements in their location should use the App only where the required permission or supervision exists.

11. Changes

This Privacy Policy may be updated when App functionality, services used by the App or legal requirements change.

If a material change requires renewed notice, the current document may be shown again in the App for reading and acknowledgement.

12. Publisher and privacy contact

For processing for which the publisher is legally responsible, the publisher or data controller is the developer identified in the App's current Google Play listing.

Privacy inquiries and requests to exercise applicable rights may be submitted through the developer contact mechanism shown on that listing. Requests concerning processing controlled by Google or another third-party service provider may also need to be directed to that provider.

13. Language

The full Privacy Policy is provided in Turkish and English.

For other supported App languages, the document name, reading guidance and acknowledgement interface may be localized, but a separate legal summary is not created.

If the Turkish and English texts are interpreted differently, the English text is used as the reference to the extent permitted by applicable mandatory law.
''';

  static const String _termsEnglish = '''
TERMS OF USE — LEFFERION PRIME - MIZAN

1. Acceptance of the Terms

Before normal use of MIZAN, the user must open and read through the Privacy Policy and confirm having been informed, then separately open, read through and accept these Terms of Use through the required in-App flow.

Permanent PRO Purchase Terms are not part of that initial acceptance. They are shown and accepted separately when the user chooses to purchase Permanent PRO.

Advertising privacy or consent choices are also handled separately from acceptance of these Terms.

2. Purpose of the App

MIZAN is a personal record-keeping and reporting tool for debts, bills, subscriptions, rents, installments, expenses, income, payments and related financial records.

MIZAN is not a bank, financial institution, investment adviser, accountant, tax adviser, legal adviser, credit provider or debt-collection service.

Users should independently verify important payment dates, amounts, interest, taxes, fees and contractual obligations with the relevant institution or professional when appropriate.

3. User responsibility

The user is responsible for the accuracy of information entered into the App.

Important financial information should be independently checked where an incorrect, incomplete or outdated entry could have consequences.

Reports and calculations produced by the App depend on the data entered by the user.

4. Free access

Free access requires an active internet connection.

Advertising may be shown by the App during free access.

Free access does not unlock saving or sharing a real PDF report.

If internet connectivity is unavailable, access for a free user may be restricted until connectivity is restored.

5. PRO access

While PRO access is active, offline use and PDF report export are available.

The App is designed not to show App-served advertising while PRO access is active.

Temporary or Permanent PRO can use active PRO features except features expressly reserved for Permanent PRO.

CSV backup export and merging a CSV backup into existing records are reserved for Permanent PRO access.

Permanent PRO is a one-time purchase. It is not a subscription and does not create an automatically recurring charge.

6. Advertising

Free users may encounter advertising at appropriate points in App use.

These Terms do not promise a particular number of ads, display interval, behavioral threshold or availability of advertising inventory.

Advertising services and related privacy choices operate under the applicable third-party service rules and the user's valid privacy choices.

7. Local data and backup

MIZAN's core financial records are stored locally on the user's device.

There is no mandatory publisher-operated account, financial-record cloud or guaranteed remote backup service for those records.

Device failure, loss, reset, clearing App data or removing the App without a usable backup can cause data loss.

The user is responsible for protecting exported files and backups that the user creates.

8. Third-party services

MIZAN may interact with third-party systems such as Google Play, advertising services and file-sharing or storage services selected by the user.

The availability and operation of those services, and processing performed within their own systems, are controlled by the relevant service providers.

9. Acceptable use

Users must not attempt to bypass PRO access controls, purchase validation, advertising controls or privacy mechanisms without authorization.

Creating false PRO access by modifying the App or local data, distributing modified builds that misrepresent access, introducing malicious software or using the App unlawfully is prohibited.

10. Availability and changes

The App may be updated for security, bug fixes, performance, compatibility or feature improvements.

Changes to the operating system, Google Play, advertising services, device capabilities or other third-party infrastructure may affect some App functions.

The App and third-party services are not guaranteed to operate without interruption or error in every circumstance.

11. Intellectual property

The user receives a limited, personal, non-exclusive and non-transferable right to use MIZAN for lawful personal use.

The App software, branding, original design elements and other protected materials remain with their respective rights holders.

12. Responsibility and verification

To the extent permitted by applicable law, MIZAN does not guarantee that every calculation, report, export, local record or third-party service will be uninterrupted and error-free in every circumstance.

The user remains responsible for independently verifying important financial obligations.

These Terms do not remove mandatory consumer rights or other rights that applicable law does not permit to be limited.

13. Refusal of terms

A user who does not confirm having read the current Privacy Policy or does not accept the current Terms of Use cannot proceed to normal App use.

Refusing the Permanent PRO Purchase Terms does not cancel the user's general App acceptance; it only prevents the Permanent PRO purchase from being started.

14. Changes to these Terms

If these Terms are materially changed, the current version may be shown again for reading and acceptance before normal App use continues.

15. Language and severability

The full Terms of Use are provided in Turkish and English.

For other supported App languages, document names, guidance and the acceptance interface may be localized, but a separate legal summary is not created.

If the Turkish and English texts are interpreted differently, the English text is used as the reference to the extent permitted by applicable mandatory law.

If any provision cannot be applied, the remaining provisions are not automatically invalidated.
''';

  static const String _purchaseEnglish = '''
PERMANENT PRO PURCHASE TERMS — LEFFERION PRIME - MIZAN

1. Separate acceptance required

A Permanent PRO purchase cannot be started until these Purchase Terms have been shown to the user, read through to the end and explicitly accepted.

Previous acceptance of the Privacy Policy and Terms of Use does not constitute acceptance of these Purchase Terms.

When the user chooses to purchase Permanent PRO, this document is opened. After the required reading flow is completed, the user must explicitly choose to accept the Purchase Terms before the Google Play purchase flow can begin.

2. Permanent PRO product

Permanent PRO is a one-time in-App product purchased through Google Play and is not consumed through ordinary use.

Permanent PRO is not a subscription.

It does not renew automatically and does not create a periodically recurring subscription charge.

3. Price and payment

The price and currency applicable to the purchase are shown by Google Play at the time of the transaction.

Regional pricing, currency and any taxes applied to the transaction may be determined by Google Play according to the relevant store and user region.

Payment is carried out through Google Play. MIZAN does not directly receive or store the user's payment-card information on a publisher-operated server.

4. Permanent PRO features

With valid Permanent PRO access, the user can use the App's core local features offline, save and share PDF reports, export CSV backups, and merge a CSV backup into existing records.

The App is designed not to show App-served advertising while Permanent PRO access is active.

The current PRO screen can be reviewed before purchase to see the features offered with Permanent PRO.

5. Meaning of “Permanent”

Permanent PRO means that the purchased access is not a subscription or a time-limited package that automatically expires after a preset period.

It does not guarantee that a particular phone, operating-system version, Google Play infrastructure or any other third-party technology will remain available forever without change.

6. Google Play ownership validation

Recognition of Permanent PRO is associated with valid ownership information reported through Google Play.

This does not require a separate publisher-operated user account or a publisher-operated financial-record server.

7. User data

Starting or ending Permanent PRO access does not by itself delete financial records stored on the user's device.

The handling of user records, backups and exported files remains subject to the local-data structure described in the Privacy Policy and Terms of Use.

8. Future price changes

A different future sale price for Permanent PRO does not convert an already completed one-time purchase into a recurring payment.

New prices apply only according to the terms shown by Google Play when the relevant purchase is made.

9. Service availability

Temporary unavailability of third-party infrastructure such as Google Play or the device operating system may affect starting a purchase or recognition of PRO access.

The App and third-party services are not guaranteed to operate without interruption in every circumstance.

10. Refunds, cancellation and defective digital content

Google Play processes the payment transaction. Refund or cancellation requests are handled through the channels and rules made available by Google Play, subject to applicable law and the user's country or region.

If the purchased access is not delivered, does not work as described or the digital content is defective, the user may use Google Play's support or refund channel and may contact the developer through the contact information shown on the App's Google Play listing.

Nothing in these Purchase Terms removes remedies or mandatory consumer rights that cannot lawfully be waived.

11. Language and severability

The full Permanent PRO Purchase Terms are provided in Turkish and English.

For other supported App languages, the document name, reading guidance and acceptance interface may be localized, but a separate legal summary is not created.

If the Turkish and English texts are interpreted differently, the English text is used as the reference to the extent permitted by applicable mandatory law.

If any provision cannot be applied, the remaining provisions are not automatically invalidated.
''';

  static LegalDocument document(LegalDocumentType type, String languageTag) =>
      switch (type) {
        LegalDocumentType.privacy => const LegalDocument(
          type: LegalDocumentType.privacy,
          title: 'Privacy Policy',
          localizedOverview: '',
          englishMaster: _privacyEnglish,
        ),
        LegalDocumentType.terms => const LegalDocument(
          type: LegalDocumentType.terms,
          title: 'Terms of Use',
          localizedOverview: '',
          englishMaster: _termsEnglish,
        ),
        LegalDocumentType.purchase => const LegalDocument(
          type: LegalDocumentType.purchase,
          title: 'Permanent PRO Purchase Terms',
          localizedOverview: '',
          englishMaster: _purchaseEnglish,
        ),
      };
}
