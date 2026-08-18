import 'zh/mizan_zh_core.dart';
import 'zh/mizan_zh_dashboard.dart';
import 'zh/mizan_zh_records.dart';
import 'zh/mizan_zh_reports.dart';
import 'zh/mizan_zh_settings.dart';
import 'zh/mizan_zh_validation.dart';

const Map<String, String> mizanChinese = <String, String>{
  ...mizanChineseCore,
  ...mizanChineseDashboard,
  ...mizanChineseRecords,
  ...mizanChineseReports,
  ...mizanChineseSettings,
  ...mizanChineseValidation,
};
