import 'nl/mizan_nl_core.dart';
import 'nl/mizan_nl_dashboard.dart';
import 'nl/mizan_nl_records.dart';
import 'nl/mizan_nl_reports.dart';
import 'nl/mizan_nl_settings.dart';
import 'nl/mizan_nl_validation.dart';

const Map<String, String> mizanDutch = <String, String>{
  ...mizanDutchCore,
  ...mizanDutchValidation,
  ...mizanDutchDashboard,
  ...mizanDutchRecords,
  ...mizanDutchReports,
  ...mizanDutchSettings,
};
