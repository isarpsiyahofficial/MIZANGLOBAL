from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    if not target.exists():
        return ""
    return target.read_text(encoding="utf-8")


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def require_all(text: str, tokens: list[str], label: str, failures: list[str]) -> None:
    missing = [token for token in tokens if token not in text]
    require(not missing, f"{label}: {', '.join(missing)}", failures)


def require_absent(text: str, tokens: list[str], label: str, failures: list[str]) -> None:
    present = [token for token in tokens if token in text]
    require(not present, f"{label}: {', '.join(present)}", failures)


def main() -> int:
    failures: list[str] = []

    pubspec = read("pubspec.yaml")
    models = read("lib/models/mizan_models.dart")
    controller = read("lib/controllers/mizan_controller.dart")
    people = read("lib/screens/people_screen.dart")
    forms = read("lib/screens/record_form_dialogs.dart")
    expenses = read("lib/screens/expenses_screen.dart")
    dashboard = read("lib/screens/dashboard_screen.dart")
    reports = read("lib/screens/reports_screen.dart")
    settings = read("lib/screens/settings_screen.dart")
    store = read("lib/services/local_store.dart")
    csv_backup = read("lib/services/csv_backup_service.dart")
    report_service = read("lib/services/report_service.dart")
    pdf_gate = read("lib/services/pdf_report_service.dart")
    pdf_renderer = read("lib/services/pdf_report_renderer.dart")
    pdf_report = pdf_gate + "\n" + pdf_renderer
    scaffold = read("lib/widgets/responsive_scaffold.dart")
    global_catalog = read("lib/global/global_catalog.dart")
    global_setup = read("lib/screens/global_setup_screen.dart")
    global_picker = read("lib/widgets/global_picker_dialog.dart")

    android_workflow = read(".github/workflows/android-release.yml")
    final_workflow = read(".github/workflows/final-branch-ci.yml")
    monetization_workflow = read(".github/workflows/monetization-ci.yml")
    android_config = read("tools/configure_android.py")
    android_gradle = read("android/app/build.gradle.kts")
    android_manifest = read("android/app/src/main/AndroidManifest.xml")
    main_activity = read(
        "android/app/src/main/kotlin/com/lefferionprime/mizanglobal/MainActivity.kt"
    )

    monetization_config = read("lib/monetization/monetization_config.dart")
    monetization_policy = read("lib/monetization/monetization_policy.dart")
    monetization_controller = read("lib/monetization/monetization_controller.dart")
    ad_service = read("lib/monetization/ad_service.dart")
    purchase_service = read("lib/monetization/purchase_service.dart")
    entitlement_store = read("lib/monetization/premium_entitlement_store.dart")
    promo_service = read("lib/monetization/local_promo_service.dart")
    monetization_strings = read("lib/monetization/monetization_strings.dart")
    offline_gate = read("lib/monetization/free_offline_gate.dart")
    network_gate = read("lib/monetization/network_gate_service.dart")
    pro_branding = read("lib/monetization/pro_branding.dart")
    premium_screen = read("lib/screens/premium_screen.dart")
    pdf_access_card = read("lib/widgets/pdf_premium_access_card.dart")
    backup_access_card = read("lib/widgets/backup_premium_access_card.dart")
    backup_pro_test = read("test/backup_pro_entitlement_contract_test.dart")
    backup_report_language_test = read("test/backup_report_language_isolation_test.dart")
    pdf_access_test = read("test/pdf_premium_access_card_test.dart")
    pdf_access_integration_test = read("test/pdf_access_integration_contract_test.dart")
    legal_documents = read("lib/legal/legal_documents.dart")
    legal_turkish = read("lib/legal/legal_turkish_documents.dart")
    legal_consent_strings = read("lib/legal/legal_consent_strings.dart")
    legal_acceptance = read("lib/legal/legal_acceptance_store.dart")
    legal_consent_screen = read("lib/screens/legal_consent_screen.dart")
    legal_document_screen = read("lib/screens/legal_document_screen.dart")
    hebrew_scope_validator = read("tools/validate_hebrew_localization_scope.py")
    hindi_scope_validator = read("tools/validate_hindi_localization_scope.py")

    all_tests = "\n".join(
        path.read_text(encoding="utf-8") for path in (ROOT / "test").glob("*_test.dart")
    )
    shipping_sources = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (ROOT / "lib").rglob("*.dart")
        if path.name != "reminder_engine.dart"
    )

    require_all(
        android_workflow,
        [
            "tools/configure_android.py",
            "Verify serverless monetization native integration",
            "dart format --output=none --set-exit-if-changed lib test",
            "flutter analyze --fatal-warnings",
            "flutter test --reporter expanded",
            "flutter build apk --release",
            "MIZAN_ALLOW_TEST_RELEASE",
            "actions/upload-artifact@v4",
        ],
        "Android CI/build gate incomplete",
        failures,
    )
    require_absent(
        android_workflow,
        ["flutter create . --platforms=android", "contents: write"],
        "Android CI contains destructive or temporary write behavior",
        failures,
    )
    require_all(
        final_workflow,
        [
            "all_29_language_pairwise_isolation_test.dart",
            "all_29_language_deep_surface_test.dart",
            "validate_hebrew_localization_scope.py",
            "validate_hindi_localization_scope.py",
            "monetization_contract_test.dart",
            "legal_acceptance_contract_test.dart",
            "reward_entitlement_binding_contract_test.dart",
            "record_currency_persistence_contract_test.dart",
            "csv_multicurrency_identity_test.dart",
            "report_multicurrency_isolation_test.dart",
            "Build four internal release APKs",
            "SOURCE_SHA",
            "mizan-global/final-exact-sha",
        ],
        "Final exact-SHA audit incomplete",
        failures,
    )
    require_all(
        monetization_workflow,
        [
            "Verify serverless monetization source",
            "dart analyze --fatal-warnings",
            "flutter test",
            "flutter build apk --debug",
            "MIZAN_TEST_ADS=true",
        ],
        "Monetization CI gate incomplete",
        failures,
    )
    for validator, label in (
        (hebrew_scope_validator, "Hebrew"),
        (hindi_scope_validator, "Hindi"),
    ):
        require_all(
            validator,
            [
                "EXPECTED_INTEGRATED_LANGUAGES",
                "LEGACY_I18N",
                "Twenty-nine-language runtime changed unexpectedly",
            ],
            f"Standalone {label} scope validation is stale",
            failures,
        )
    require_absent(
        monetization_workflow + final_workflow,
        ["npm run check", "wrangler", "backend/monetization-worker/src/index.ts"],
        "CI still depends on removed publisher backend",
        failures,
    )

    require_all(
        android_config,
        [
            'ANDROID_PACKAGE = "com.lefferionprime.mizanglobal"',
            'ANDROID_LABEL = "LEFFERION PRIME - MIZAN GLOBAL"',
            "Forbidden server verification integration remains",
        ],
        "Android configuration gate incomplete",
        failures,
    )
    require_absent(
        android_config,
        ["shutil.rmtree(main_activity_root", "flutter create"],
        "Android configurator contains destructive regeneration",
        failures,
    )
    require_all(
        android_manifest,
        [
            "android.permission.INTERNET",
            "android.permission.ACCESS_NETWORK_STATE",
            "com.google.android.gms.ads.APPLICATION_ID",
            "${admobApplicationId}",
        ],
        "Android monetization manifest incomplete",
        failures,
    )
    require_absent(
        android_manifest + android_gradle + main_activity,
        [
            "android.permission.POST_NOTIFICATIONS",
            "android.permission.SCHEDULE_EXACT_ALARM",
            "android.permission.RECEIVE_BOOT_COMPLETED",
            "flutterlocalnotifications",
            "play_integrity",
            "device_identity",
            "StandardIntegrityManager",
            "com.google.android.play:integrity",
            "MIZAN_MONETIZATION_API",
            "MIZAN_PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER",
            "MIZAN_REQUIRE_BILLING_BACKEND",
        ],
        "Removed platform/backend integration remains",
        failures,
    )
    require_all(
        main_activity,
        ["FlutterActivity", "class MainActivity : FlutterActivity()"],
        "Minimal Android activity incomplete",
        failures,
    )
    require_all(
        android_gradle,
        [
            'namespace = "com.lefferionprime.mizanglobal"',
            'applicationId = "com.lefferionprime.mizanglobal"',
            "MIZAN_ADMOB_APP_ID",
            "MIZAN_ADMOB_INTERSTITIAL_ID",
            "MIZAN_ADMOB_REWARDED_ID",
            "MIZAN_RELEASE_KEYSTORE_PATH",
            "Production release refused",
        ],
        "Production Android fail-closed configuration incomplete",
        failures,
    )

    require("assets/brand/lefferion-prime-logo.png" in pubspec, "Logo asset missing", failures)
    require_all(
        pubspec,
        [
            "path_provider:",
            "file_picker:",
            "csv:",
            "pdf:",
            "printing:",
            "connectivity_plus:",
            "google_mobile_ads:",
            "in_app_purchase:",
            "shared_preferences:",
            "crypto:",
            "http:",
        ],
        "Required product dependency missing",
        failures,
    )
    require_absent(
        pubspec,
        ["flutter_local_notifications", "flutter_timezone", "android_intent_plus"],
        "Removed notification/battery dependency remains",
        failures,
    )

    for asset_path, expected_count in [
        ("assets/data/languages_v1.json", 29),
        ("assets/data/countries_v1.json", 161),
        ("assets/data/currencies_v1.json", 154),
    ]:
        require(asset_path in pubspec, f"Global asset absent from pubspec: {asset_path}", failures)
        try:
            payload = json.loads(read(asset_path))
            require(
                payload.get("count") == expected_count,
                f"Global catalog count incorrect: {asset_path}",
                failures,
            )
            require(
                len(payload.get("items", [])) == expected_count,
                f"Global catalog item count incorrect: {asset_path}",
                failures,
            )
        except Exception as error:
            failures.append(f"Global catalog unreadable: {asset_path}: {error}")

    require_all(
        global_catalog + global_setup + global_picker,
        [
            "GlobalCatalogRepository",
            "languages_v1.json",
            "countries_v1.json",
            "currencies_v1.json",
            "showLanguagePicker",
            "showCountryPicker",
            "showCurrencyPicker",
        ],
        "Global setup/catalog/picker architecture incomplete",
        failures,
    )

    require_all(
        models,
        [
            "class PaymentRecord",
            "class DebtProduct",
            "class PersonalDebtEntry",
            "class SubscriptionEntry",
            "class BillEntry",
            "class RentEntry",
            "class IncomeEntry",
            "currencyCode",
            "defaultCurrencyCode",
            "recentCurrencyCodes",
            "currentSchemaVersion = 15",
            "recordReferencesAt",
            "actualPaymentTotals",
            "factory MizanState.empty()",
            "factory MizanState.freshInstall()",
        ],
        "Core state / record-currency model incomplete",
        failures,
    )
    require_all(
        controller,
        [
            "addPerson(",
            "addDebtProduct(",
            "addPersonalDebt(",
            "addBill(",
            "addSubscription(",
            "addRent(",
            "addPayment(",
            "addExpense(",
            "addIncome(",
            "mergeFromBackup",
            "completeGlobalSetup(",
            "updateGlobalPreferences(",
            "validateMizanState(",
        ],
        "Controller write flows incomplete",
        failures,
    )
    require_all(
        store,
        [
            "mizan_state.json",
            "mizan_state.backup.json",
            "mizan_state.tmp.json",
            "writeAsString(encoded, flush: true)",
            "StoreLoadSource.backup",
            "MizanState.freshInstall()",
        ],
        "Atomic local store / recovery incomplete",
        failures,
    )
    require_all(
        csv_backup,
        [
            "MIZAN_CSV_BACKUP",
            "MizanState.fromJson",
            "CsvMergeResult",
            "mergeStates",
            "currencyCode",
            "income",
            "subscription",
            "rent_installment",
        ],
        "CSV backup / multi-currency merge incomplete",
        failures,
    )

    require_all(
        models + forms,
        [
            "showPersonForm",
            "showBankForm",
            "showDebtForm",
            "showPersonalDebtForm",
            "showBillForm",
            "showSubscriptionForm",
            "showRentForm",
            "showPaymentForm",
        ],
        "Record forms incomplete",
        failures,
    )
    require_all(
        people,
        ["showRecordDetails", "RecordNotesPanel", "RecordType.bill", "RecordType.subscription"],
        "Records screen incomplete",
        failures,
    )
    require_all(
        expenses,
        ["enum _ExpenseView", "_PaymentExpenseGroups", "updateExpense", "deleteExpense"],
        "Expense screen incomplete",
        failures,
    )
    require_all(
        dashboard,
        ["showRecordDetails"],
        "Dashboard detail/report linkage incomplete",
        failures,
    )
    require_all(
        scaffold,
        ["NavigationRail", "NavigationBar", "SafeArea", "LayoutBuilder"],
        "Responsive navigation incomplete",
        failures,
    )

    require_all(
        reports + report_service,
        [
            "ReportPeriod.daily",
            "ReportPeriod.weekly",
            "ReportPeriod.monthly",
            "ReportPeriod.yearly",
            "ReportPeriod.allTime",
            "incomeDetails",
            "totalIncome",
            "afterPayments",
            "finalNet",
            "paymentTotalsByType",
            "expenseTotalsByCategory",
            "personDebtDetails",
            "PDF",
        ],
        "Detailed report calculation/UI incomplete",
        failures,
    )
    require_all(
        pdf_report,
        ["PdfReportService", "pw.Document", "PdfPageFormat.a4", "_ensure", "_newPage"],
        "PDF renderer incomplete",
        failures,
    )
    require_all(
        pdf_gate,
        [
            "PremiumEntitlementStore",
            "PremiumPdfRequiredException",
            "PRO is required",
            ".hasPremiumAt(nowUtc)",
            "throw const PremiumPdfRequiredException()",
            "renderer.PdfReportService().build(report)",
        ],
        "PRO PDF entitlement service gate incomplete",
        failures,
    )
    require_all(
        reports + pdf_access_card,
        [
            "MonetizationScope.maybeOf(context)",
            "PdfPremiumAccessCard",
            "isPremium: monetization?.isPremium ?? false",
            "pdf-pro-locked",
            "pdf-pro-unlocked",
            "pdf-preview-button",
            "pdf-save-enabled",
            "pdf-share-enabled",
            "showPdfSamplePreview",
        ],
        "PRO PDF live UI lock/preview/unlock gate incomplete",
        failures,
    )
    require_absent(
        reports,
        ["class _PdfActions extends StatelessWidget"],
        "Legacy always-visible PDF export actions remain",
        failures,
    )
    require_all(
        pdf_access_test + pdf_access_integration_test,
        [
            "free user sees PDF lock and sample preview but no export actions",
            "active PRO removes the lock and enables real PDF actions",
            "PDF access copy covers exactly every supported MIZAN language",
            "reports screen drives PDF access from live monetization entitlement",
            "PDF renderer remains protected behind local PRO entitlement",
        ],
        "PRO PDF lock/unlock regression coverage incomplete",
        failures,
    )

    require_all(
        monetization_config,
        [
            "premium_lifetime",
            "Duration(seconds: 10)",
            "Duration(seconds: 120)",
            "behaviorActionThreshold = 3",
            "rewardedViewsRequiredForDailyPremium = 3",
            "Duration(days: 1)",
            "androidInterstitialTestId",
            "androidRewardedTestId",
            "defaultValue: !kReleaseMode",
        ],
        "Monetization constants/config incomplete",
        failures,
    )
    require_absent(
        monetization_config,
        [
            "MIZAN_MONETIZATION_API",
            "MIZAN_PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER",
            "MIZAN_REQUIRE_BILLING_BACKEND",
        ],
        "Removed monetization backend configuration remains",
        failures,
    )
    require_all(
        monetization_policy,
        [
            "AdBreakTrigger.time",
            "AdBreakTrigger.behavior",
            "timeAdEligible",
            "behaviorAdEligible",
            "completedMeaningfulActions >=",
            "premium || online",
            "canExportPdf",
        ],
        "Monetization policy incomplete",
        failures,
    )
    require_all(
        monetization_controller,
        [
            "_entitlementStore.load()",
            "synchronizeOwnedPurchases",
            "_adService.showRewarded()",
            "recordRewardedViewAndGrantIfEligible()",
            "_promoService.redeem(code)",
            "onTimeAdBreak",
            "onBehaviorAdBreak",
            "recordMeaningfulCompletedAction",
            "setPremiumSuppressed",
        ],
        "Serverless monetization orchestration incomplete",
        failures,
    )
    require_absent(
        monetization_controller,
        [
            "MizanMonetizationApi",
            "_syncTemporaryEntitlement",
            "createRewardSession",
            "rewardSessionStatus",
        ],
        "Removed server monetization orchestration remains",
        failures,
    )
    require_all(
        ad_service,
        [
            "setPremiumSuppressed",
            "disposeLoadedAds",
            "onUserEarnedReward",
            "androidInterstitialAdUnitId",
            "androidRewardedAdUnitId",
        ],
        "Ad suppression/reward callback integration incomplete",
        failures,
    )
    require_absent(
        ad_service,
        ["ServerSideVerificationOptions", "setServerSideOptions"],
        "Removed rewarded-ad server verification remains",
        failures,
    )
    require_all(
        network_gate,
        ["networkPollInterval", "reachabilityUrl", "checkNow", "Timer.periodic"],
        "Real-internet free-mode gate incomplete",
        failures,
    )
    require_all(
        purchase_service,
        [
            "queryPastPurchases",
            "buyNonConsumable",
            "PurchaseStatus.purchased",
            "PurchaseStatus.restored",
            "setPermanentPremium",
            "clearPermanentPremium",
            "completePurchase",
            "serverVerificationData",
            "sha256.convert",
            "purchaseFingerprint",
        ],
        "Google Play purchase/automatic restore flow incomplete",
        failures,
    )
    require_absent(
        purchase_service,
        ["verifyGooglePlayPurchase", "MizanMonetizationApi"],
        "Publisher billing backend dependency remains",
        failures,
    )
    require_all(
        entitlement_store,
        [
            "setPermanentPremium",
            "clearPermanentPremium",
            "grantTemporaryUntil",
            "grantTemporaryDuration",
            "recordRewardedViewAndGrantIfEligible",
            "lastObservedUtc",
            "rewardedViewsRequiredForDailyPremium",
            "permanentPurchaseFingerprint",
            "monetization.permanentPurchaseFingerprint.v1",
        ],
        "Persistent local PRO entitlement store incomplete",
        failures,
    )
    require_all(
        promo_service,
        [
            "Hmac(sha256",
            "Duration(days: 7)",
            "Duration(days: 3)",
            "40d844f4232ec3ccfec81fd04e7256d1b3fcfcc471f2439629d21a6d80eccdaa",
            "578af8ebcd839ce76ca6028fb78275d8afd4f4093cc7a01477130cbd1873bd26",
            "monetization.promo.used.v2",
        ],
        "Embedded local promotion validation incomplete",
        failures,
    )
    require_absent(
        promo_service,
        ["package:http", "http.Client", "Uri.parse", "/v1/promo"],
        "Promotion validator contains network dependency",
        failures,
    )
    require(
        not (ROOT / "backend/monetization-worker").exists(),
        "Publisher monetization Worker directory remains",
        failures,
    )
    require(
        not (ROOT / "lib/monetization/monetization_api.dart").exists(),
        "Publisher monetization API client remains",
        failures,
    )

    require_all(
        pro_branding + premium_screen + offline_gate + settings,
        ["ProBranding", "PRO"],
        "PRO user-facing branding layer incomplete",
        failures,
    )
    require_all(
        settings + backup_access_card + monetization_strings + csv_backup,
        [
            "BackupPremiumAccessCard",
            "isPermanentPremium",
            "isTemporaryPremium",
            "backup-pro-locked",
            "backup-pro-unlocked",
            "backup-export-enabled",
            "backup-import-enabled",
            "permanentPurchaseFingerprint",
            "entitlement_proof",
            "google_play_permanent",
            "google_play_non_consumable",
        ],
        "Permanent-PRO-only backup gate/proof incomplete",
        failures,
    )
    require_absent(
        csv_backup,
        ["temporaryUntilUtc", "rewardedViewsToday", "promo.used"],
        "Temporary/promo entitlement leaked into backup proof",
        failures,
    )
    require_all(
        backup_pro_test + backup_report_language_test,
        [
            "temporary PRO remains backup-locked",
            "only permanent PRO exposes backup actions",
            "backup and PDF access catalogs cover exactly the same 29 languages",
            "raw exception or TR filename fallbacks",
        ],
        "Backup/PRO/report language regression coverage incomplete",
        failures,
    )
    require_all(
        monetization_strings + legal_consent_strings,
        ["tr", "en", "es", "pt-BR", "pt-PT", "zh", "ja", "ko", "vi", "th", "sw"],
        "29-language monetization/legal UI surface incomplete",
        failures,
    )
    require(
        not (ROOT / "lib/legal/legal_locale_summaries.dart").exists(),
        "Removed per-locale legal summary adapter remains",
        failures,
    )
    require(
        not (ROOT / "lib/legal/serverless_legal_overview.dart").exists(),
        "Removed serverless legal overview remains",
        failures,
    )
    require_all(
        legal_acceptance + legal_consent_screen + legal_document_screen,
        [
            "mizan_legal_acceptance_version",
            "mizan_purchase_terms_version",
            "LegalDocumentType.privacy",
            "LegalDocumentType.terms",
            "LegalDocumentType.purchase",
            "Türkçe",
            "English",
        ],
        "Separated general/purchase legal acceptance flow incomplete",
        failures,
    )
    require_all(
        legal_documents + legal_turkish,
        ["Google Play", "explicitly accepted", "Kalıcı PRO", "ayrıca kabul edilir"],
        "Controlling Turkish/English legal contract incomplete",
        failures,
    )
    require_absent(
        legal_documents + legal_turkish,
        [
            "Cloudflare",
            "Play Integrity",
            "rewarded",
            "24 hours",
            "ESMANUR",
            "silently",
        ],
        "Legal documents contain removed infrastructure or implementation details",
        failures,
    )

    require_absent(
        shipping_sources,
        ["services/reminder_engine.dart"],
        "Legacy reminder planner imported by shipping runtime",
        failures,
    )
    require(
        not (ROOT / "lib/services/notification_service.dart").exists(),
        "Notification platform service remains",
        failures,
    )

    critical_tests = [
        "monetization_contract_test.dart",
        "legal_acceptance_contract_test.dart",
        "reward_entitlement_binding_contract_test.dart",
        "all_29_language_pairwise_isolation_test.dart",
        "all_29_language_deep_surface_test.dart",
        "all_29_language_final_contract_test.dart",
        "record_currency_persistence_contract_test.dart",
        "csv_multicurrency_identity_test.dart",
        "csv_legacy_tr_currency_migration_test.dart",
        "report_multicurrency_isolation_test.dart",
        "global_preferences_backup_invariants_test.dart",
        "global_release_integrity_contract_test.dart",
        "pdf_premium_access_card_test.dart",
        "pdf_access_integration_contract_test.dart",
        "backup_pro_entitlement_contract_test.dart",
        "backup_report_language_isolation_test.dart",
    ]
    for test_name in critical_tests:
        require(
            (ROOT / "test" / test_name).is_file(),
            f"Critical test missing: {test_name}",
            failures,
        )
    require_all(
        all_tests,
        [
            "PdfReportService",
            "premium_lifetime",
            "behavior advertising uses three actions",
            "rewarded PRO progress is local",
            "shipping monetization has no publisher backend dependency",
            "legal documents use only Turkish and English full masters",
            "temporary PRO remains backup-locked",
            "raw exception or TR filename fallbacks",
        ],
        "Critical regression contract tokens incomplete",
        failures,
    )

    if failures:
        print("Mizan structural validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(
        "Mizan structural validation passed: serverless monetization, direct Google Play "
        "restore, three-reward temporary PRO, three-action behavior ads, 29-language "
        "globalization, record-based multi-currency, reports/PDF, persistence and "
        "exact-SHA release gates are present."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
