import 'package:flutter/material.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';

Future<void> runDeliveryEtaPillTests() async {
  await testGroup('Tier 1: Delivery ETA Pill', () async {
    await testCase('Renders default delivery ETA text', () {
      const pill = DeliveryEtaPill();
      expect(pill.etaText, equals('⚡ Delivery in 10-15 mins'));
      expect(pill.compact, isFalse);
    });

    await testCase('Renders custom ETA string when provided', () {
      const pill = DeliveryEtaPill(etaText: '⚡ Delivery in 8 mins');
      expect(pill.etaText, equals('⚡ Delivery in 8 mins'));
    });

    await testCase('Supports compact mode flag', () {
      const compactPill = DeliveryEtaPill(compact: true);
      expect(compactPill.compact, isTrue);
    });

    await testCase('Maintains flash icon styling', () {
      const pill = DeliveryEtaPill();
      final widget = pill.build(TestBuildContext());
      expect(widget is Container, isTrue);
      final container = widget as Container;
      expect(container.child is Row, isTrue);
      final row = container.child as Row;
      expect(row.children.isNotEmpty, isTrue);
      final iconWidget = row.children.first;
      expect(iconWidget is Icon, isTrue);
    });

    await testCase('Container key is delivery_eta_pill', () {
      const pill = DeliveryEtaPill();
      final widget = pill.build(TestBuildContext());
      expect((widget as Container).key, equals(const Key('delivery_eta_pill')));
    });

    await testCase('Renders bold text style inside pill', () {
      const pill = DeliveryEtaPill();
      final row = (pill.build(TestBuildContext()) as Container).child as Row;
      final textWidget = row.children.last as Text;
      expect(textWidget.data, equals('⚡ Delivery in 10-15 mins'));
      expect(textWidget.style.fontWeight, equals(FontWeight.bold));
    });

    await testCase('Compact mode applies reduced vertical padding', () {
      const normalPill = DeliveryEtaPill(compact: false);
      const compactPill = DeliveryEtaPill(compact: true);
      final normalContainer = normalPill.build(TestBuildContext()) as Container;
      final compactContainer = compactPill.build(TestBuildContext()) as Container;
      final normalPadding = normalContainer.padding as EdgeInsets;
      final compactPadding = compactContainer.padding as EdgeInsets;
      expect(compactPadding.top < normalPadding.top, isTrue);
    });

    await testCase('Handles custom Express delivery copy', () {
      const expressPill = DeliveryEtaPill(etaText: '🚀 Lightning fast in 7 mins');
      expect(expressPill.etaText, contains('7 mins'));
    });
  });
}

class TestBuildContext implements BuildContext {
  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() => null;
  @override
  dynamic getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() => null;
}

Future<void> main() async {
  await runDeliveryEtaPillTests();
  globalTestSummary.printReport('Tier 1 DeliveryEtaPill');
}
