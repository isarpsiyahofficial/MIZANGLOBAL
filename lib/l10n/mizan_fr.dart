import 'fr/mizan_fr_core.dart';
import 'fr/mizan_fr_dashboard.dart';
import 'fr/mizan_fr_records.dart';
import 'fr/mizan_fr_reports.dart';
import 'fr/mizan_fr_settings.dart';
import 'fr/mizan_fr_validation.dart';

// REVIEWED FRENCH LOCALIZATION — 791/791 STATIC VALUES REQUIRED.
// France-oriented product language. User-authored content is never translated.
const Map<String, String> mizanFrench = <String, String>{
  ...mizanFrenchCore,
  ...mizanFrenchValidation,
  ...mizanFrenchDashboard,
  ...mizanFrenchRecords,
  ...mizanFrenchReports,
  ...mizanFrenchSettings,
};
