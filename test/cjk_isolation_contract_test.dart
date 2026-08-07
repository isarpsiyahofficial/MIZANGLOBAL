import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main(){
  test('Korean Japanese Chinese isolation contract is binding before any CJK runtime is enabled',(){
    final contract=File('docs/localization/cjk-isolation-contract.md').readAsStringSync();
    for(final marker in const['Korean (`ko-KR`)','Japanese (`ja-JP`)','Simplified Chinese (`zh-CN`)','Reports, charts, PDF','notifications','791-key','29/161/154','ko -> ja -> zh -> ko'])expect(contract,contains(marker),reason:marker);
  });
}
