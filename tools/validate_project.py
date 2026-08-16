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
    monetization_api = read("lib/monetization/monetization_api.dart")
    ad_service = read("lib/monetization/ad_service.dart")
    purchase_service = read("lib/monetization/purchase_service.dart")
    entitlement_store = read("lib/monetization/premium_entitlement_store.dart")
    monetization_strings = read("lib/monetization/monetization_strings.dart")
    offline_gate = read("lib/monetization/free_offline_gate.dart")
    network_gate = read("lib/monetization/network_gate_service.dart")
    pro_branding = read("lib/monetization/pro_branding.dart")
    premium_screen = read("lib/screens/premium_screen.dart")
    legal_documents = read("lib/legal/legal_documents.dart")
    legal_summaries = read("lib/legal/legal_locale_summaries.dart")

    worker = read("backend/monetization-worker/src/index.ts")
    worker_schema = read("backend/monetization-worker/schema.sql")
    worker_config = read("backend/monetization-worker/wrangler.jsonc")

    all_tests = "\n".join(
        path.read_text(encoding="utf-8") for path in (ROOT / "test").glob("*_test.dart")
    )
    shipping_sources = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (ROOT / "lib").rglob("*.dart")
        if path.name != "reminder_engine.dart"
    )

    # Build and CI must preserve the checked-in native security integration.
    require_all(
        android_workflow,
        [
            "tools/configure_android.py",
            "Verify monetization native integration is present",
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
        ["flutter create . --platforms=android"],
        "CI must not regenerate and erase native monetization code",
        failures,
    )
    require_all(
        final_workflow,
        [
            "all_29_language_pairwise_isolation_test.dart",
            "all_29_language_deep_surface_test.dart",
            "monetization_contract_test.dart",
            "record_currency_persistence_contract_test.dart",
            "csv_multicurrency_identity_test.dart",
            "report_multicurrency_isolation_test.dart",
            "Build ABI-specific internal release APKs",
            "SOURCE_SHA",
            "mizan-global/final-exact-sha",
        ],
        "Final exact-SHA audit incomplete",
        failures,
    )
    require_all(
        monetization_workflow,
        [
            "dart analyze --fatal-warnings",
            "flutter test",
            "npm run check",
            "MIZAN_TEST_ADS=true",
        ],
        "Monetization CI gate incomplete",
        failures,
    )

    # Android identity, permissions and anti-abuse channels.
    require_all(
        android_config,
        [
            'ANDROID_PACKAGE = "com.lefferionprime.mizanglobal"',
            'ANDROID_LABEL = "LEFFERION PRIME - MIZAN GLOBAL"',
            "device_identity",
            "play_integrity",
            "requestStandardToken",
            "StandardIntegrityManager",
        ],
        "Android configuration preservation gate incomplete",
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
        android_manifest + android_gradle,
        [
            "android.permission.POST_NOTIFICATIONS",
            "android.permission.SCHEDULE_EXACT_ALARM",
            "android.permission.RECEIVE_BOOT_COMPLETED",
            "flutterlocalnotifications",
        ],
        "Removed notification/alarm platform capability remains",
        failures,
    )
    require_all(
        main_activity,
        [
            "device_identity",
            "play_integrity",
            "Settings.Secure.ANDROID_ID",
            "StandardIntegrityManager",
            "prepareIntegrityToken",
            "setRequestHash",
        ],
        "Native device identity / Play Integrity channel incomplete",
        failures,
    )
    require_all(
        android_gradle,
        [
            'namespace = "com.lefferionprime.mizanglobal"',
            'applicationId = "com.lefferionprime.mizanglobal"',
            "com.google.android.play:integrity:1.6.0",
            "MIZAN_ADMOB_APP_ID",
            "MIZAN_ADMOB_INTERSTITIAL_ID",
            "MIZAN_ADMOB_REWARDED_ID",
            "MIZAN_MONETIZATION_API",
            "MIZAN_PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER",
            "MIZAN_REQUIRE_BILLING_BACKEND",
            "MIZAN_RELEASE_KEYSTORE_PATH",
            "Production release refused",
        ],
        "Production release fail-closed configuration incomplete",
        failures,
    )

    # Product dependencies and global catalogs.
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

    # Core persistence and record-based multi-currency model.
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
            "class ExpenseEntry",
            "currencyCode",
            "defaultCurrencyCode",
            "recentCurrencyCodes",
            "currentSchemaVersion = 14",
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
            "_validateState(",
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

    # Major screens and responsive shell remain present.
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
        ["showRecordDetails", "availableReportMonths"],
        "Dashboard detail/report linkage incomplete",
        failures,
    )
    require_all(
        scaffold,
        ["NavigationRail", "NavigationBar", "SafeArea", "LayoutBuilder"],
        "Responsive navigation incomplete",
        failures,
    )

    # Reports: calculation, PDF renderer and PRO access gate are intentionally split.
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
            "kReleaseMode",
            "MIZAN_TEST_LOCALE",
        ],
        "PRO PDF entitlement gate incomplete",
        failures,
    )

    # Free/PRO monetization contract.
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
            "MIZAN_MONETIZATION_API",
            "MIZAN_PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER",
            "defaultValue: !kReleaseMode",
        ],
        "Monetization constants/config incomplete",
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
            "_syncTemporaryEntitlement",
            "createRewardSession",
            "showRewarded(customData: sessionId)",
            "rewardSessionStatus",
            "onTimeAdBreak",
            "onBehaviorAdBreak",
            "recordMeaningfulCompletedAction",
            "setPremiumSuppressed",
        ],
        "Monetization orchestration incomplete",
        failures,
    )
    reward_start = monetization_controller.find("Future<bool> watchRewardedForDailyPremium()")
    reward_end = monetization_controller.find("Future<PromoRedemptionResult> redeemPromo")
    reward_flow = (
        monetization_controller[reward_start:reward_end]
        if reward_start >= 0 and reward_end > reward_start
        else ""
    )
    require_absent(
        reward_flow,
        ["recordRewardedView", "grantTemporaryDuration"],
        "Rewarded PRO cannot trust a local counter",
        failures,
    )
    require_all(
        ad_service,
        [
            "setPremiumSuppressed",
            "disposeLoadedAds",
            "ServerSideVerificationOptions",
            "customData",
            "androidInterstitialAdUnitId",
            "androidRewardedAdUnitId",
        ],
        "Ad suppression / SSV integration incomplete",
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
            "verifyGooglePlayPurchase",
            "setPermanentPremium",
            "clearPermanentPremium",
            "completePurchase",
        ],
        "Google Play purchase/automatic restore flow incomplete",
        failures,
    )
    require_all(
        entitlement_store,
        [
            "setPermanentPremium",
            "clearPermanentPremium",
            "grantTemporaryUntil",
            "applyVerifiedTemporaryState",
            "lastObservedUtc",
        ],
        "Persistent offline PRO entitlement store incomplete",
        failures,
    )
    require_all(
        monetization_api,
        [
            "hashedDeviceId",
            "requestStandardToken",
            "createRewardSession",
            "rewardSessionStatus",
            "syncTemporaryEntitlement",
            "verifyGooglePlayPurchase",
        ],
        "Monetization backend client incomplete",
        failures,
    )

    # User-facing PRO branding and legal contracts.
    require_all(
        pro_branding + premium_screen + offline_gate + settings,
        ["ProBranding", "PRO"],
        "PRO user-facing branding layer incomplete",
        failures,
    )
    require_all(
        monetization_strings + legal_summaries,
        ["tr", "en", "es", "pt-BR", "pt-PT", "zh", "ja", "ko", "vi", "th", "sw"],
        "29-language monetization/legal surface incomplete",
        failures,
    )
    require_all(
        legal_documents,
        ["English", "controlling", "restore", "refund", "ESMANUR", "LEFFERION", "Google Play"],
        "English controlling legal/purchase contract incomplete",
        failures,
    )

    # Server-side authority: promo, reward SSV and Billing validation.
    require_all(
        worker,
        [
            "ESMANUR: 7",
            "LEFFERION: 3",
            "mizan-promo-v1",
            "decodeIntegrityToken",
            "MEETS_DEVICE_INTEGRITY",
            "ADMOB_VERIFIER_KEYS_URL",
            "verifyAdMobSsv",
            "transaction_id",
            "/v1/reward/admob/ssv",
            "/v1/reward/session",
            "/v1/entitlement/temporary/sync",
            "/v1/billing/google/verify",
            "ACKNOWLEDGEMENT_STATE_PENDING",
            "PURCHASED",
        ],
        "Monetization Worker authority incomplete",
        failures,
    )
    require_all(
        worker_schema,
        [
            "promo_redemptions",
            "billing_purchases",
            "rewarded_sessions",
            "rewarded_daily_state",
            "rewarded_transactions",
            "applied_at_utc",
        ],
        "Monetization D1 schema incomplete",
        failures,
    )
    require_all(
        worker_config,
        [
            "EXPECTED_PACKAGE_NAME",
            "EXPECTED_PRODUCT_ID",
            "EXPECTED_REWARDED_AD_UNIT_ID",
            "REQUIRE_PLAY_INTEGRITY",
            "production",
        ],
        "Worker production configuration incomplete",
        failures,
    )

    # Shipping runtime must not reintroduce the removed notification engine.
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

    # Regression suite must explicitly contain the current global/revenue gates.
    critical_tests = [
        "monetization_contract_test.dart",
        "all_29_language_pairwise_isolation_test.dart",
        "all_29_language_deep_surface_test.dart",
        "all_29_language_final_contract_test.dart",
        "record_currency_persistence_contract_test.dart",
        "csv_multicurrency_identity_test.dart",
        "csv_legacy_tr_currency_migration_test.dart",
        "report_multicurrency_isolation_test.dart",
        "global_preferences_backup_invariants_test.dart",
        "global_release_integrity_contract_test.dart",
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
            "812",
            "PdfReportService",
            "premium_lifetime",
            "AdBreakTrigger.behavior",
            "ServerSideVerificationOptions",
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
        "Mizan structural validation passed: current Android security, PRO monetization, "
        "29-language globalization, record-based multi-currency, reports/PDF, persistence, "
        "backend authority and exact-SHA CI gates are present."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
