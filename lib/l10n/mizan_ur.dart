import 'ur/mizan_ur_core.dart';
import 'ur/mizan_ur_dashboard.dart';
import 'ur/mizan_ur_records.dart';
import 'ur/mizan_ur_reports.dart';
import 'ur/mizan_ur_settings.dart';
import 'ur/mizan_ur_validation.dart';

const Map<String, String> mizanUrdu = <String, String>{
  ...mizanUrduCore,
  ...mizanUrduDashboard,
  ...mizanUrduRecords,
  ...mizanUrduReports,
  ...mizanUrduSettings,
  ...mizanUrduValidation,
};
