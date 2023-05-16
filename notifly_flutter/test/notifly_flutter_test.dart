import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifly_flutter/notifly_flutter.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNotiflyFlutterPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements NotiflyFlutterPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotiflyFlutter', () {
    late NotiflyFlutterPlatform notiflyFlutterPlatform;

    setUp(() {
      notiflyFlutterPlatform = MockNotiflyFlutterPlatform();
      NotiflyFlutterPlatform.instance = notiflyFlutterPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => notiflyFlutterPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => notiflyFlutterPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
