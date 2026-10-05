import 'package:qwik_grocery_app/models/customer_profile.dart';
import '../harness/mock_api_client.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_fixtures.dart';

Future<void> runAddressAndInstructionEdgesTests() async {
  await testGroup('Tier 2: Address Validation & Delivery Instruction Boundaries', () async {
    final client = MockApiClient();

    await testCase('Formatted address joins non-empty components with comma and space', () {
      const addr = SavedAddress(
        id: 'addr_test',
        label: 'Home',
        recipientName: 'Aarav',
        phone: '9876543210',
        line1: '101 Palm Grove',
        line2: 'MG Road',
        landmark: 'Near Metro',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560001',
      );
      final formatted = addr.formatted;
      expect(formatted, contains('101 Palm Grove'));
      expect(formatted, contains('MG Road'));
      expect(formatted, contains('Bengaluru'));
      expect(formatted, contains('560001'));
    });

    await testCase('hasMapPin is true when both latitude and longitude are present', () {
      expect(TestFixtures.addrHome.hasMapPin, isTrue);
      const noPinAddr = SavedAddress(
        id: 'no_pin',
        label: 'Other',
        recipientName: 'Test',
        phone: '9876543210',
        line1: 'Road 5',
        city: 'Pune',
        state: 'MH',
        postalCode: '411001',
      );
      expect(noPinAddr.hasMapPin, isFalse);
    });

    await testCase('addAddress generates unique address ID if none provided', () async {
      const newAddr = SavedAddress(
        id: '',
        label: 'Gym',
        recipientName: 'Aarav',
        phone: '9876543210',
        line1: 'Fitness Club',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560001',
      );
      final created = await client.addAddress(newAddr);
      expect(created.id.isNotEmpty, isTrue);
      expect(created.label, equals('Gym'));

      final profile = await client.profile();
      expect(profile.addresses.length, equals(3));
    });

    await testCase('deleteAddress removes specified address cleanly', () async {
      final initialCount = (await client.profile()).addresses.length;
      await client.deleteAddress(TestFixtures.addrWork.id);
      final updatedProfile = await client.profile();
      expect(updatedProfile.addresses.length, equals(initialCount - 1));
      expect(updatedProfile.addresses.any((a) => a.id == TestFixtures.addrWork.id), isFalse);
    });

    await testCase('addPaymentMethod adds card with lastFour digits', () async {
      final pm = await client.addPaymentMethod(
        type: 'card',
        label: 'Axis Bank Card',
        lastFour: '1234',
      );
      expect(pm.type, equals('card'));
      expect(pm.lastFour, equals('1234'));
      expect(pm.display, contains('1234'));
    });

    await testCase('addPaymentMethod adds UPI with upiId', () async {
      final pm = await client.addPaymentMethod(
        type: 'upi',
        label: 'Paytm UPI',
        upiId: 'test@paytm',
      );
      expect(pm.type, equals('upi'));
      expect(pm.upiId, equals('test@paytm'));
      expect(pm.display, contains('test@paytm'));
    });

    await testCase('deletePaymentMethod removes target payment method', () async {
      final initialPmCount = (await client.profile()).paymentMethods.length;
      await client.deletePaymentMethod('pm_upi_1');
      final updatedProfile = await client.profile();
      expect(updatedProfile.paymentMethods.length, equals(initialPmCount - 1));
    });

    await testCase('Order creation accepts multiple comma-separated delivery instructions', () async {
      const instructions = 'Leave at door, Avoid calling, Don\'t ring bell';
      final order = await client.createOrder(
        items: [{'productId': TestFixtures.p1Onions.id, 'quantity': 1}],
        name: 'Aarav',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        instructions: instructions,
      );
      expect(order.delivery!['instructions'], equals(instructions));
    });

    await testCase('Order creation with null instructions defaults gracefully to empty string', () async {
      final order = await client.createOrder(
        items: [{'productId': TestFixtures.p1Onions.id, 'quantity': 1}],
        name: 'Aarav',
        phone: '9876543210',
        address: TestFixtures.addrHome.formatted,
        instructions: null,
      );
      expect(order.delivery!['instructions'], equals(''));
    });

    await testCase('CustomerProfile fromJson parses addresses and payment methods', () {
      final json = {
        'name': 'Rohan Sen',
        'email': 'rohan@example.com',
        'addresses': [
          {
            'id': 'addr_rohan',
            'label': 'Home',
            'recipientName': 'Rohan',
            'phone': '9988776655',
            'line1': 'Flat 12',
            'city': 'Mumbai',
            'state': 'MH',
            'postalCode': '400001',
          }
        ],
        'paymentMethods': [
          {
            'id': 'pm_rohan',
            'type': 'upi',
            'label': 'GPay',
            'upiId': 'rohan@okhdfc',
          }
        ],
      };
      final profile = CustomerProfile.fromJson(json);
      expect(profile.name, equals('Rohan Sen'));
      expect(profile.addresses.length, equals(1));
      expect(profile.paymentMethods.length, equals(1));
    });
  });
}

Future<void> main() async {
  await runAddressAndInstructionEdgesTests();
  globalTestSummary.printReport('Tier 2 AddressAndInstructionEdges');
}
