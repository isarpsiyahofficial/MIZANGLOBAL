import 'ko/mizan_ko_core.dart';
import 'ko/mizan_ko_dashboard.dart';
import 'ko/mizan_ko_records.dart';
import 'ko/mizan_ko_reports.dart';
import 'ko/mizan_ko_settings.dart';
import 'ko/mizan_ko_validation.dart';

const Map<String, String> mizanKorean = <String, String>{
  ...mizanKoreanCore,
  ...mizanKoreanDashboard,
  ...mizanKoreanRecords,
  ...mizanKoreanReports,
  ...mizanKoreanSettings,
  ...mizanKoreanValidation,
};
