import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

/// The iOS implementation of [NotiflyFlutterPlatform].
class NotiflyFlutterIOS extends NotiflyFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('notifly_flutter_ios');

  /// Registers this class as the default instance of [NotiflyFlutterPlatform]
  static void registerWith() {
    NotiflyFlutterPlatform.instance = NotiflyFlutterIOS();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<void> initialize(
    String projectId,
    String username,
    String password,
  ) async {
    await methodChannel.invokeMethod('initialize', {
      'projectId': projectId,
      'username': username,
      'password': password,
    });
  }

  @override
  Future<void> setUserId(
    String? userId,
  ) async {
    await methodChannel.invokeMethod('setUserId', {
      'userId': userId,
    });
  }

  @override
  Future<void> setUserProperties(Map<String, Object> params) async {
    final typeMap = <String, String>{};
    params.forEach((key, value) {
      if (value is int || value is bool) {
        typeMap[key] = value.runtimeType.toString();
      }
    });

    await methodChannel.invokeMethod('setUserProperties', {
      'userProperties': params,
      'typeMap': typeMap,
    });
  }

  @override
  Future<void> trackEvent(
    String eventName,
    Map<String, Object>? eventParams,
    List<String>? segmentationEventParamKeys,
  ) async {
    await methodChannel.invokeMethod('trackEvent', {
      'eventName': eventName,
      'eventParams': eventParams,
      'segmentationEventParamKeys': segmentationEventParamKeys,
    });
  }
}
