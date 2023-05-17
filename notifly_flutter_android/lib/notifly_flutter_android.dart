import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

/// The Android implementation of [NotiflyFlutterPlatform].
class NotiflyFlutterAndroid extends NotiflyFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('notifly_flutter_android');

  /// Registers this class as the default instance of [NotiflyFlutterPlatform]
  static void registerWith() {
    NotiflyFlutterPlatform.instance = NotiflyFlutterAndroid();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<bool> initialize(String projectId, String username, String password) {
    final args = <String, dynamic>{
      'projectId': projectId,
      'username': username,
      'password': password,
    };
    return methodChannel
        .invokeMethod('initialize', args)
        .then((value) => value as bool);
  }
}
