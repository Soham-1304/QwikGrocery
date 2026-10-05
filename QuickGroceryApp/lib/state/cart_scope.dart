import 'package:flutter/widgets.dart';

import 'cart_controller.dart';

/// InheritedNotifier providing zero-prop-drilling access to [CartController].
class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Obtains the [CartController] and subscribes the caller to state changes.
  static CartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'No CartScope found in context');
    return scope!.notifier!;
  }

  /// Obtains the [CartController] without throwing if not found.
  static CartController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    return scope?.notifier;
  }

  /// Obtains the [CartController] without registering a listener (does not rebuild).
  static CartController cartOf(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<CartScope>();
    final scope = element?.widget as CartScope?;
    assert(scope != null, 'No CartScope found in context');
    return scope!.notifier!;
  }
}
