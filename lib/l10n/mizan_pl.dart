import 'pl/mizan_pl_core.dart';
import 'pl/mizan_pl_dashboard.dart';
import 'pl/mizan_pl_records.dart';
import 'pl/mizan_pl_reports.dart';
import 'pl/mizan_pl_settings.dart';
import 'pl/mizan_pl_validation.dart';

const Map<String, String> mizanPolish = <String, String>{
  ...mizanPolishCore,
  ...mizanPolishDashboard,
  ...mizanPolishRecords,
  ...mizanPolishReports,
  ...mizanPolishSettings,
  ...mizanPolishValidation,
};
