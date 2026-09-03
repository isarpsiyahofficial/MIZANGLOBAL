import 'fil/mizan_fil_core.dart';
import 'fil/mizan_fil_dashboard.dart';
import 'fil/mizan_fil_records.dart';
import 'fil/mizan_fil_reports.dart';
import 'fil/mizan_fil_settings.dart';
import 'fil/mizan_fil_validation.dart';

const Map<String, String> mizanFilipino = <String, String>{
  ...mizanFilipinoCore,
  ...mizanFilipinoDashboard,
  ...mizanFilipinoRecords,
  ...mizanFilipinoReports,
  ...mizanFilipinoSettings,
  ...mizanFilipinoValidation,
};
