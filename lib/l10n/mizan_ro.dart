import 'ro/mizan_ro_core.dart';
import 'ro/mizan_ro_dashboard.dart';
import 'ro/mizan_ro_records.dart';
import 'ro/mizan_ro_reports.dart';
import 'ro/mizan_ro_settings.dart';
import 'ro/mizan_ro_validation.dart';

const Map<String, String> mizanRomanian = <String, String>{
  ...mizanRomanianCore,
  ...mizanRomanianDashboard,
  ...mizanRomanianRecords,
  ...mizanRomanianReports,
  ...mizanRomanianSettings,
  ...mizanRomanianValidation,
};
