from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def require_all(text: str, tokens: list[str], label: str, failures: list[str]) -> None:
    missing = [token for token in tokens if token not in text]
    require(not missing, f"{label}: {', '.join(missing)}", failures)


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
    pdf_report = read("lib/services/pdf_report_service.dart")
    scaffold = read("lib/widgets/responsive_scaffold.dart")
    global_catalog = read("lib/global/global_catalog.dart")
    global_setup = read("lib/screens/global_setup_screen.dart")
    global_picker = read("lib/widgets/global_picker_dialog.dart")
    workflow = read(".github/workflows/android-release.yml")
    android_config = read("tools/configure_android.py")
    requirements = read("docs/REQUIREMENTS_250_PLUS.md")
    all_tests = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (ROOT / "test").glob("*_test.dart")
    )

    require_all(
        workflow,
        [
            "flutter create . --platforms=android",
            "tools/configure_android.py",
            "flutter analyze --fatal-warnings",
            "flutter test --reporter expanded",
            "flutter build apk --release",
            "actions/upload-artifact@v4",
        ],
        "CI/build adımları eksik",
        failures,
    )
    require_all(
        android_config,
        [
            'ANDROID_PACKAGE = "com.lefferionprime.mizanglobal"',
            'ANDROID_LABEL = "LEFFERION PRIME - MIZAN GLOBAL"',
            "android.permission.POST_NOTIFICATIONS",
            "flutterlocalnotifications",
            "shutil.rmtree",
        ],
        "GLOBAL Android kimliği veya bildirim temizliği eksik",
        failures,
    )
    require("assets/brand/lefferion-prime-logo.png" in pubspec, "Logo asset yolu eksik", failures)
    for asset_path, expected_count in [
        ("assets/data/languages_v1.json", 29),
        ("assets/data/countries_v1.json", 161),
        ("assets/data/currencies_v1.json", 154),
    ]:
        require(asset_path in pubspec, f"Global asset pubspec içinde eksik: {asset_path}", failures)
        try:
            payload = json.loads(read(asset_path))
            require(payload.get("count") == expected_count, f"Global katalog sayısı hatalı: {asset_path}", failures)
            require(len(payload.get("items", [])) == expected_count, f"Global katalog öğeleri eksik: {asset_path}", failures)
        except Exception as error:
            failures.append(f"Global katalog okunamadı: {asset_path}: {error}")
    require("flutter_local_notifications" not in pubspec, "Bildirim paketi ürün bağımlılıklarından kaldırılmadı", failures)
    require("flutter_timezone" not in pubspec and "timezone:" not in pubspec, "Bildirim zamanlama bağımlılıkları kaldırılmadı", failures)
    require(not (ROOT / "lib/services/notification_service.dart").exists(), "Bildirim platform servisi ürün kaynağında kaldı", failures)
    require("path_provider" in pubspec, "Dosya tabanlı yerel kayıt paketi eksik", failures)
    require("file_picker" in pubspec and "csv:" in pubspec, "CSV yedek paketleri eksik", failures)
    require("pdf:" in pubspec and "printing:" in pubspec, "PDF rapor paketleri eksik", failures)
    require("android_intent_plus" not in pubspec, "Gereksiz pil ayarı bağımlılığı kaldırılmadı", failures)

    require_all(
        models,
        [
            "class PaymentRecord",
            "class DebtProduct",
            "class PersonalDebtEntry",
            "class SubscriptionEntry",
            "class BillEntry",
            "class RentEntry",
            "class DueScheduleItem",
            "enum CreditorType", "enum DebtDueMode",
            "enum PaymentFrequency", "enum PaymentEntryType",
            "paidInstallmentCount", "remainingInstallmentCount",
            "personalDebts",
            "subscriptions",
            "recordReferencesAt",
            "bankDebtTotal", "actualPaymentTotals", "dueAmountAt",
            "personalCorporateDebtTotal",
            "subscriptionTotal",
            "factory MizanState.empty()", "factory MizanState.freshInstall()",
            "setupCompleted", "appLanguageTag", "debtRegionCountryCode",
            "defaultCurrencyCode", "recentCurrencyCodes",
        ],
        "Genişletilmiş veri modeli eksik",
        failures,
    )
    require_all(
        controller,
        [
            "addPerson(", "updatePerson(", "deletePerson(",
            "addBankGroup(", "addDebtProduct(",
            "addPersonalDebt(", "updatePersonalDebt(", "deletePersonalDebt(",
            "addBill(", "addSubscription(", "updateSubscription(",
            "addRent(", "addPayment(", "updatePayment(", "deletePayment(",
            "addNote(", "deleteNote(",
            "addExpenseCategory(", "deleteExpenseCategory(",
            "addExpense(", "updateExpense(", "deleteExpense(",
            "ONAYLIYORUM", "restoreFromBackup(",
            "entryType: entryType", "allowStorageRecovery", "_storageReady", "_validateState(",
            "completeGlobalSetup(", "updateGlobalPreferences(",
        ],
        "Controller akışları eksik",
        failures,
    )
    require_all(
        store,
        [
            "mizan_state.json",
            "mizan_state.backup.json",
            "mizan_state.tmp.json",
            "writeAsString(encoded, flush: true)",
            "_tryRead(temporary)",
            "_tryRead(primary)",
            "StoreLoadSource.backup",
            "MizanState.freshInstall()",
        ],
        "Yerel atomik kayıt/yedek kurtarma eksik",
        failures,
    )
    require_all(
        global_catalog + "\n" + global_setup + "\n" + global_picker,
        [
            "GlobalCatalogRepository", "languages_v1.json", "countries_v1.json",
            "currencies_v1.json", "showLanguagePicker", "showCountryPicker",
            "showCurrencyPicker", "Kurulumu tamamla", "Dil ara",
            "Ülke adı veya kod ara", "Ad, ISO kodu veya sembol ara",
        ],
        "Global ilk kurulum veya arama ekranları eksik",
        failures,
    )
    require_all(
        csv_backup,
        [
            "MIZAN_CSV_BACKUP",
            "personal_corporate_debt",
            "subscription",
            "rent_installment",
            "snapshot",
            "MizanState.fromJson",
        ],
        "CSV yedekleme eksik",
        failures,
    )
    shipping_sources = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (ROOT / "lib").rglob("*.dart")
        if path.name != "reminder_engine.dart"
    )
    require(
        "services/reminder_engine.dart" not in shipping_sources and "reminder_engine.dart" not in shipping_sources,
        "Legacy reminder planner shipping runtime tarafından import ediliyor",
        failures,
    )
    require(
        not any(token in controller for token in [
            "rescheduleNotifications",
            "requestNotificationPermissions",
            "notificationHealth",
            "scheduleNotificationTest",
        ]),
        "Controller içinde kaldırılan bildirim runtime API'si kaldı",
        failures,
    )
    require(
        not any(token in settings for token in [
            "Bildirim sistemi",
            "Ödeme hatırlatmaları",
            "Günlük gider hatırlatmaları",
            "Dakik bildirim izni",
            "test bildirimi",
        ]),
        "Ayarlar ekranında kullanıcıya açık bildirim sistemi kaldı",
        failures,
    )

    require_all(
        models + "\n" + forms,
        [
            "showPersonForm", "showBankForm", "showDebtForm",
            "showPersonalDebtForm", "showBillForm", "showSubscriptionForm",
            "showRentForm", "showPaymentForm", "Alacaklı türü",
            "Çek numarası", "Senet numarası", "Sıradaki ödeme tarihi", "Ödeme tarihi yöntemi", "Her ayın kaçıncı günü?",
            "Taksit ödemesi", "Borç kapama", "Kısmi ödeme",
            "Kalan taksit sayısı",
        ],
        "Form akışları eksik",
        failures,
    )
    require_all(
        people,
        [
            "Kayıt sahibi", "Kişi detayları", "Kişi detaylarını aç", "Banka Borçları", "Kişisel ve Kurumsal Borçlar",
            "RecordType.bill.groupLabel", "RecordType.subscription.groupLabel", "RecordType.rent.groupLabel",
            "showRecordDetails", "Ödeme geçmişi", "RecordNotesPanel",
        ],
        "Kayıtlar ekranı eksik",
        failures,
    )
    require_all(expenses, ["Bugün", "Bu ay", "Tarih aralığı", "ONAYLIYORUM", "updateExpense", "deleteExpense"], "Gider ekranı eksik", failures)
    require_all(expenses, ["enum _ExpenseView", "_PaymentExpenseGroups", "Bütün harcamalar"], "Gider ekranı üçlü görünümü eksik", failures)
    require_all(dashboard, ["Gelir özeti", "Gelir bilgisi belirtilmemiş", "Ödemeler sonrası kalan", "Ödeme ve gider sonrası net", "Kalan toplam borç detayı", "Kritik ödemeler", "showRecordDetails", "Önümüzdeki 7 gün"], "Ana sayfa detayları eksik", failures)
    require_all(reports + "\n" + report_service, ["Rapor kapsamı", "Günlük", "Haftalık", "Aylık", "Yıllık", "Tüm zamanlar", "Gelir ve net durum", "Gelir ayrıntıları", "Ödemeler sonrası kalan", "Ödeme ve gider sonrası net", "Gerçekleşen harcamaların dağılımı", "Seçili dönem gider özeti", "Bütün harcamalar", "Kalan ödeme yükünün dağılımı", "Gider dağılımı", "Kişi bazında güncel kalan borç", "PDF indir", "PDF paylaş", "Tüm kişileri kapsa"], "Ayrıntılı rapor/PDF ekranı eksik", failures)
    require_all(report_service, ["enum ReportPeriod", "ReportPeriod.daily", "ReportPeriod.weekly", "ReportPeriod.monthly", "ReportPeriod.yearly", "ReportPeriod.allTime", "selectedPersonIds", "incomeDetails", "totalIncome", "afterPayments", "finalNet", "installmentDetails", "paymentTotalsByType", "expenseTotalsByCategory", "personDebtDetails", "_fullRemainingReferences"], "Rapor hesaplama servisi eksik", failures)
    require_all(pdf_report, ["PdfReportService", "pw.Document", "PdfPageFormat.a4", "Gelir ayrıntıları", "Gelir bilgisi belirtilmemiş", "Toplam gider sonrası net", "Gerçekleşen ödeme ayrıntıları", "Gider ayrıntıları", "Kalan ödeme ayrıntıları", "Kişi bazında güncel kalan borç", "_ensure", "_newPage"], "PDF rapor servisi eksik", failures)
    require_all(reports, ["expandedDays", "report-person-", "ExpansionTile("], "Rapor açılır-kapanır ayrıntıları eksik", failures)
    require_all(settings, ["Dil, ülke ve para birimi", "Yerel veri güvenliği", "CSV yedeğini dışa aktar", "CSV yedeğini mevcut verilerle birleştir", "Anlık yerel kayıt"], "Ayarlar ve güvenli yedek ekranı eksik", failures)
    require("Planlanan bildirim" not in settings, "Planlanan bildirim sayacı ürün ekranında kaldı", failures)
    require("Alarm" not in settings and "alarm" not in settings, "Kullanıcıya açık alarm sistemi kaldırılmadı", failures)
    require("NotificationPresentationMode" not in models and "AlarmRepeatMode" not in models, "Alarm sunum modeli kaldırılmadı", failures)
    require("Pil optimizasyonu" not in settings, "Pil optimizasyonu butonu kaldırılmadı", failures)
    require("örnek kayıtlarla sıfırla" not in settings.lower(), "Tehlikeli örnek sıfırlama alanı kaldırılmadı", failures)
    require_all(scaffold, ["NavigationRail", "NavigationBar", "SafeArea", "LayoutBuilder"], "Responsive gezinme eksik", failures)

    require_all(
        all_tests,
        [
            "MizanState.empty()", "paymentCount", "StoreLoadSource.backup",
            "CSV", "physicalSize",
            "textScaleFactorTestValue", "ONAYLIYORUM",
            "ödeme yalnız kaynak", "Kalan toplam borç", "Kişi detayları", "Her ayın belirli günü", "sıradaki ödeme tutarını",
            "PaymentEntryType.installment",
            "IncomeEntry", "IncomeFrequency.monthly", "availableReportMonths",
            "ReportPeriod.allTime", "PdfReportService", "%PDF",
        ],
        "Kritik otomatik test kapsamı eksik",
        failures,
    )

    require_all(models, ["currentSchemaVersion = 14", "enum IncomeFrequency", "class IncomeEntry", "incomes", "availableReportMonths", "unpaidDueDatesAt", "firstScheduledDueDate", "manualOverduePeriods", "manualOverdueSince"], "Gelir veya dönem modeli eksik", failures)
    require_all(controller, ["_nextMonthlyDueDate", "mergeFromBackup", "addIncome", "updateIncome", "deleteIncome"], "Gelir/vade veya birleştirme controller akışı eksik", failures)
    require_all(csv_backup, ["'income'", "MizanState.fromJson", "CsvMergeResult", "mergeStates", "categoryIdMap"], "Gelir veya güvenli CSV birleştirme eksik", failures)

    require_all(dashboard, ["Bugünkü ödemelere yapılan gider", "Bu ay toplam gider", "Normal giderler ile banka"], "Ana sayfa toplam gider özeti eksik", failures)
    require_all(reports, ["Seçili dönem gider özeti", "Normal giderler", "Ödemeler", "Bütün harcamalar"], "Rapor filtreyle uyumlu gider özeti eksik", failures)
    require_all(models, ["actualPaymentTotalForDay", "actualPaymentTotalForMonth", "totalOutflowForDay", "totalOutflowForMonth"], "Birleşik gider hesapları eksik", failures)

    numbered = re.findall(r"^\d{3}\.", requirements, flags=re.MULTILINE)
    require(len(numbered) >= 360, f"Ana gereksinim sayısı 360 altında: {len(numbered)}", failures)

    if failures:
        print("Mizan yapısal doğrulaması başarısız:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(
        f"Mizan yapısal doğrulaması geçti; {len(numbered)} ana gereksinim takip ediliyor. "
        "Davranış, responsive, CSV, dil izolasyonu ve kayıt bazlı para birimi testleri ayrıca çalıştırılmalıdır."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
