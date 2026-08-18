import 'vi/mizan_vi_core.dart';
import 'vi/mizan_vi_dashboard.dart';
import 'vi/mizan_vi_records.dart';
import 'vi/mizan_vi_reports.dart';
import 'vi/mizan_vi_settings.dart';
import 'vi/mizan_vi_validation.dart';

const Map<String, String> mizanVietnamese = <String, String>{
  ...mizanVietnameseCore,
  ...mizanVietnameseDashboard,
  ...mizanVietnameseRecords,
  ...mizanVietnameseReports,
  ...mizanVietnameseSettings,
  ...mizanVietnameseValidation,
};
