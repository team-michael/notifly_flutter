// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

// Project imports:
import 'package:notifly_flutter_ios/notifly_flutter_ios.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotiflyFlutterIOS', () {
    const kPlatformName = 'iOS';
    late NotiflyFlutterIOS notiflyFlutter;
    late List<MethodCall> log;

    setUp(() async {
      notiflyFlutter = NotiflyFlutterIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notiflyFlutter.methodChannel,
              (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      NotiflyFlutterIOS.registerWith();
      expect(NotiflyFlutterPlatform.instance, isA<NotiflyFlutterIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await notiflyFlutter.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
