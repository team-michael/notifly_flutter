import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifly_flutter_platform_interface/src/method_channel_notifly_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelNotiflyFlutter', () {
    late MethodChannelNotiflyFlutter methodChannelNotiflyFlutter;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelNotiflyFlutter = MethodChannelNotiflyFlutter();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannelNotiflyFlutter.methodChannel,
              (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    tearDown(log.clear);

    test('getPlatformName', () async {
      final platformName = await methodChannelNotiflyFlutter.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(platformName, equals(kPlatformName));
    });
  });
}
