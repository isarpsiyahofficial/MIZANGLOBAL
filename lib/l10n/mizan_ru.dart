import 'ru/mizan_ru_core.dart';
import 'ru/mizan_ru_dashboard.dart';
import 'ru/mizan_ru_records.dart';
import 'ru/mizan_ru_reports.dart';
import 'ru/mizan_ru_settings.dart';
import 'ru/mizan_ru_validation.dart';

const Map<String, String> mizanRussian = <String, String>{
  ...mizanRussianCore,
  ...mizanRussianDashboard,
  ...mizanRussianRecords,
  ...mizanRussianReports,
  ...mizanRussianSettings,
  ...mizanRussianValidation,
};
