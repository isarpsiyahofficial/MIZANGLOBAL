import 'it/mizan_it_core.dart';
import 'it/mizan_it_dashboard.dart';
import 'it/mizan_it_records.dart';
import 'it/mizan_it_reports.dart';
import 'it/mizan_it_settings.dart';
import 'it/mizan_it_validation.dart';

const Map<String, String> mizanItalian = <String, String>{
  ...mizanItalianCore,
  ...mizanItalianValidation,
  ...mizanItalianDashboard,
  ...mizanItalianRecords,
  ...mizanItalianReports,
  ...mizanItalianSettings,
};
