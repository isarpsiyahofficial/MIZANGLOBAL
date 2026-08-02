import 'de/mizan_de_core.dart';
import 'de/mizan_de_dashboard.dart';
import 'de/mizan_de_records.dart';
import 'de/mizan_de_reports.dart';
import 'de/mizan_de_settings.dart';
import 'de/mizan_de_validation.dart';

// REVIEWED GERMAN LOCALIZATION — 791/791 STATIC VALUES REQUIRED.
// Germany-oriented product language. User-authored content is never translated.
const Map<String, String> mizanGerman = <String, String>{
  ...mizanGermanCore,
  ...mizanGermanValidation,
  ...mizanGermanDashboard,
  ...mizanGermanRecords,
  ...mizanGermanReports,
  ...mizanGermanSettings,
};
