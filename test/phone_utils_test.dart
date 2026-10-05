import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lmrepaireagent/phone_utils.dart';

void main() {
  group('PhoneUtils Unit Tests', () {
    test('cleanPhoneNumber sanitizes phone formats correctly', () {
      expect(PhoneUtils.cleanPhoneNumber('+91 98765 43210'), '+919876543210');
      expect(PhoneUtils.cleanPhoneNumber('(123) 456-7890'), '1234567890');
      expect(PhoneUtils.cleanPhoneNumber('  +91-987-654-3210  '), '+919876543210');
      expect(PhoneUtils.cleanPhoneNumber(''), '');
    });
  });

  group('InteractivePhoneChip Widget Tests', () {
    testWidgets('renders phone number with icon and copy button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractivePhoneChip(phone: '9876543210'),
          ),
        ),
      );

      expect(find.text('9876543210'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });
}
