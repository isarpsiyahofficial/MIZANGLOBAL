import 'sw/mizan_sw_core.dart';
import 'sw/mizan_sw_dashboard.dart';
import 'sw/mizan_sw_records.dart';
import 'sw/mizan_sw_reports.dart';
import 'sw/mizan_sw_settings.dart';
import 'sw/mizan_sw_validation.dart';

const Map<String, String> mizanSwahili = <String, String>{
  ...mizanSwahiliCore,
  ...mizanSwahiliDashboard,
  ...mizanSwahiliRecords,
  ...mizanSwahiliReports,
  ...mizanSwahiliSettings,
  ...mizanSwahiliValidation,
};
