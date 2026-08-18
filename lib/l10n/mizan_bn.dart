import 'bn/mizan_bn_core.dart';
import 'bn/mizan_bn_dashboard.dart';
import 'bn/mizan_bn_records.dart';
import 'bn/mizan_bn_reports.dart';
import 'bn/mizan_bn_settings.dart';
import 'bn/mizan_bn_validation.dart';

const Map<String, String> mizanBengali = <String, String>{
  ...mizanBengaliCore,
  ...mizanBengaliDashboard,
  ...mizanBengaliRecords,
  ...mizanBengaliReports,
  ...mizanBengaliSettings,
  ...mizanBengaliValidation,
};
