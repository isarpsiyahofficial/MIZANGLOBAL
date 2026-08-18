import 'id/mizan_id_core.dart';
import 'id/mizan_id_dashboard.dart';
import 'id/mizan_id_records.dart';
import 'id/mizan_id_reports.dart';
import 'id/mizan_id_settings.dart';
import 'id/mizan_id_validation.dart';

const Map<String, String> mizanIndonesian = <String, String>{
  ...mizanIndonesianCore,
  ...mizanIndonesianDashboard,
  ...mizanIndonesianRecords,
  ...mizanIndonesianReports,
  ...mizanIndonesianSettings,
  ...mizanIndonesianValidation,
};
