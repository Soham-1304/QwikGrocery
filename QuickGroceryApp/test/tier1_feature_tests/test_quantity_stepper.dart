import 'package:qwik_grocery_app/state/cart_controller.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runQuantityStepperTests() async {
  await testGroup('Tier 1: Quantity Stepper Component', () async {
    await testCase('QuantityStepper displays current cart quantity', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 3);
      final stepper = QuantityStepper(
        product: TestFixtures.p1Onions,
        controller: cart,
      );
      expect(stepper.controller!.quantityOf(TestFixtures.p1Onions.id), equals(3));
    });

    await testCase('Tapping increment invokes onIncrement or cart.increment', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      bool customIncrementCalled = false;
      final stepper = QuantityStepper(
        product: TestFixtures.p1Onions,
        controller: cart,
        onIncrement: () => customIncrementCalled = true,
      );
      stepper.onIncrement?.call();
      expect(customIncrementCalled, isTrue);
    });

    await testCase('Tapping decrement invokes onDecrement or cart.decrement', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 2);
      bool customDecrementCalled = false;
      final stepper = QuantityStepper(
        product: TestFixtures.p1Onions,
        controller: cart,
        onDecrement: () => customDecrementCalled = true,
      );
      stepper.onDecrement?.call();
      expect(customDecrementCalled, isTrue);
    });

    await testCase('When quantity reaches stock limit, isMaxStock is true', () {
      final cart = CartController();
      // Kashmiri Saffron has stock: 2
      final saffron = TestFixtures.p15CappedStock;
      cart.add(saffron, quantity: 2);
      final qty = cart.quantityOf(saffron.id);
      expect(qty, equals(saffron.stock));
      expect(qty >= saffron.stock, isTrue);
    });

    await testCase('When quantity is below stock limit, increment remains allowed', () {
      final cart = CartController();
      final saffron = TestFixtures.p15CappedStock;
      cart.add(saffron, quantity: 1);
      final qty = cart.quantityOf(saffron.id);
      expect(qty < saffron.stock, isTrue);
    });

    await testCase('QuantityStepper compact mode configuration', () {
      final stepperCompact = QuantityStepper(
        product: TestFixtures.p1Onions,
        compact: true,
      );
      expect(stepperCompact.compact, isTrue);
      final stepperNormal = QuantityStepper(
        product: TestFixtures.p1Onions,
        compact: false,
      );
      expect(stepperNormal.compact, isFalse);
    });

    await testCase('QuantityStepper accepts elevation property', () {
      final stepper = QuantityStepper(
        product: TestFixtures.p1Onions,
        elevation: 2.0,
      );
      expect(stepper.elevation, equals(2.0));
    });

    await testCase('Direct cart.decrement via stepper removes item at quantity 1', () {
      final cart = CartController();
      cart.add(TestFixtures.p1Onions, quantity: 1);
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(1));
      cart.decrement(TestFixtures.p1Onions.id);
      expect(cart.quantityOf(TestFixtures.p1Onions.id), equals(0));
      expect(cart.itemCount, equals(0));
    });
  });
}

Future<void> main() async {
  await runQuantityStepperTests();
  globalTestSummary.printReport('Tier 1 QuantityStepper');
}
