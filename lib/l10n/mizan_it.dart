import 'it/mizan_it_core.dart';
import 'it/mizan_it_dashboard.dart';
import 'it/mizan_it_records.dart';
import 'it/mizan_it_reports.dart';
import 'it/mizan_it_settings.dart';
import 'it/mizan_it_validation.dart';

// REVIEWED ITALIAN LOCALIZATION — 791/791 STATIC VALUES REQUIRED.
// Italy-oriented product language. User-authored content is never translated.
const Map<String, String> mizanItalian = <String, String>{
  ...mizanItalianCore,
  ...mizanItalianValidation,
  ...mizanItalianDashboard,
  ...mizanItalianRecords,
  ...mizanItalianReports,
  ...mizanItalianSettings,
};
