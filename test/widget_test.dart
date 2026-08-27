import 'package:flutter_test/flutter_test.dart';
import 'package:mikrom/core/utils/validators.dart';
import 'package:mikrom/core/utils/ip_utils.dart';
import 'package:mikrom/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('MiKROM Unit Tests', () {
    test('MAC Address Validator regex validation', () {
      expect(Validators.validateMac('AA:BB:CC:DD:EE:FF'), isNull);
      expect(Validators.validateMac('00-14-22-01-23-45'), isNull);
      expect(Validators.validateMac('invalid-mac'), isNotNull);
      expect(Validators.validateMac('AA:BB:CC:DD:EE'), isNotNull);
      expect(Validators.validateMac('AA:BB:CC:DD:EE:FF:GG'), isNotNull);
    });

    test('IPv4 Validator validation', () {
      expect(Validators.validateIPv4('192.168.1.1'), isNull);
      expect(Validators.validateIPv4('10.0.0.1'), isNull);
      expect(Validators.validateIPv4('256.1.1.1'), isNotNull);
      expect(Validators.validateIPv4('abc.def.ghi.jkl'), isNotNull);
    });

    test('Subnet Mask CIDR conversions', () {
      expect(IpUtils.cidrToSubnetMask(24), equals('255.255.255.0'));
      expect(IpUtils.cidrToSubnetMask(16), equals('255.255.0.0'));
      expect(IpUtils.cidrToSubnetMask(30), equals('255.255.255.252'));

      expect(IpUtils.subnetMaskToCidr('255.255.255.0'), equals(24));
      expect(IpUtils.subnetMaskToCidr('255.255.0.0'), equals(16));
    });
  });

  testWidgets('App smoke test - renders MiKROM dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MiKromApp(),
      ),
    );

    expect(find.text('MiKROM'), findsOneWidget);
    expect(find.text('Panel de Control de Red'), findsOneWidget);
  });
}
