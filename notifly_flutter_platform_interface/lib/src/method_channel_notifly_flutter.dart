import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

/// An implementation of [NotiflyFlutterPlatform] that uses method channels.
class MethodChannelNotiflyFlutter extends NotiflyFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('notifly_flutter');

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}
