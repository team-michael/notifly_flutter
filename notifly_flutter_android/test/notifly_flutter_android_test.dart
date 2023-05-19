import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifly_flutter_android/notifly_flutter_android.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotiflyFlutterAndroid', () {
    const kPlatformName = 'Android';
    late NotiflyFlutterAndroid notiflyFlutter;
    late List<MethodCall> log;

    setUp(() async {
      notiflyFlutter = NotiflyFlutterAndroid();

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
      NotiflyFlutterAndroid.registerWith();
      expect(NotiflyFlutterPlatform.instance, isA<NotiflyFlutterAndroid>());
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
