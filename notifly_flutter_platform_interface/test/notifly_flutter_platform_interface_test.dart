import 'package:flutter_test/flutter_test.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

class NotiflyFlutterMock extends NotiflyFlutterPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('NotiflyFlutterPlatformInterface', () {
    late NotiflyFlutterPlatform notiflyFlutterPlatform;

    setUp(() {
      notiflyFlutterPlatform = NotiflyFlutterMock();
      NotiflyFlutterPlatform.instance = notiflyFlutterPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await NotiflyFlutterPlatform.instance.getPlatformName(),
          equals(NotiflyFlutterMock.mockPlatformName),
        );
      });
    });
  });
}
