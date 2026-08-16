import 'package:flutter/widgets.dart';

import 'monetization_controller.dart';

class MonetizationScope extends InheritedNotifier<MonetizationController> {
  const MonetizationScope({
    required MonetizationController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static MonetizationController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MonetizationScope>();
    assert(scope != null, 'MonetizationScope is missing above this context.');
    return scope!.notifier!;
  }
}
