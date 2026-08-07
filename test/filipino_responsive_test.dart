import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';

import 'test_support.dart';

Future<void> _pump(WidgetTester tester,Size size,double scale)async{
  tester.view.physicalSize=size;tester.view.devicePixelRatio=1;tester.platformDispatcher.textScaleFactorTestValue=scale;
  addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final state=comprehensiveState(reference:DateTime(2026,8,7)).copyWith(appLanguageTag:'fil',debtRegionCountryCode:'PH',defaultCurrencyCode:'PHP');
  final controller=MizanController(MemoryStore(state),scheduler:SpyScheduler());await controller.load();
  await tester.pumpWidget(MizanApp(controller:controller));await tester.pumpAndSettle();expect(tester.takeException(),isNull);
}
Future<void> _visit(WidgetTester tester)async{
  for(final icon in const[Icons.people_alt_outlined,Icons.shopping_bag_outlined,Icons.bar_chart_outlined,Icons.settings_outlined,Icons.space_dashboard_outlined]){
    final bar=find.byType(NavigationBar);final rail=find.byType(NavigationRail);final root=bar.evaluate().isNotEmpty?bar:rail;
    await tester.tap(find.descendant(of:root,matching:find.byIcon(icon)));await tester.pumpAndSettle();expect(tester.takeException(),isNull);
  }
}
void main(){
  testWidgets('Filipino 320x568 at 1.4x is LTR and has no Indonesian Malay or Turkish nav leakage',(tester)async{
    await _pump(tester,const Size(320,568),1.4);
    for(final text in const['Simula','Mga tala','Mga gastusin','Mga ulat','Mga setting'])expect(find.text(text),findsWidgets);
    for(final leak in const['Home','Ana sayfa','Beranda','Laman utama','Pengeluaran','Perbelanjaan','Pengaturan','Tetapan'])expect(find.text(leak),findsNothing,reason:leak);
    expect(Directionality.of(tester.element(find.text('Simula').first)),TextDirection.ltr);await _visit(tester);
  });
  testWidgets('Filipino 412x915 at 2.0x remains usable without overflow',(tester)async{await _pump(tester,const Size(412,915),2);expect(Directionality.of(tester.element(find.text('Simula').first)),TextDirection.ltr);await _visit(tester);});
}
