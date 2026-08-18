import 'de/mizan_de_core.dart';
import 'de/mizan_de_dashboard.dart';
import 'de/mizan_de_records.dart';
import 'de/mizan_de_reports.dart';
import 'de/mizan_de_settings.dart';
import 'de/mizan_de_validation.dart';

const Map<String, String> mizanGerman = <String, String>{
  ...mizanGermanCore,
  ...mizanGermanValidation,
  ...mizanGermanDashboard,
  ...mizanGermanRecords,
  ...mizanGermanReports,
  ...mizanGermanSettings,
};
