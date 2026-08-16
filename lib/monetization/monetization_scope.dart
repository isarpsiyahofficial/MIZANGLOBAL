import 'package:flutter/widgets.dart';

import 'monetization_controller.dart';

class MonetizationScope extends InheritedNotifier<MonetizationController> {
  const MonetizationScope({
    required MonetizationController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static MonetizationController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'MonetizationScope is missing above this context.');
    return controller!;
  }

  static MonetizationController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MonetizationScope>()
      ?.notifier;
}
