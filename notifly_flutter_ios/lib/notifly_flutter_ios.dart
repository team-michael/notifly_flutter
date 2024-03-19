import 'package:flutter/services.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

/// The iOS implementation of [NotiflyFlutterPlatform].
class NotiflyFlutterIOS extends NotiflyFlutterPlatform {
  /// The method channel used to interact with the native platform.
  NotiflyFlutterIOS() {
    channel = const MethodChannel('notifly_flutter_ios');
  }

  @override
  Future<String?> getPlatformName() {
    return channel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<void> initialize(
    String projectId,
    String username,
    String password,
  ) async {
    await channel.invokeMethod('initialize', {
      'projectId': projectId,
      'username': username,
      'password': password,
    });
  }

  @override
  Future<void> setUserId(
    String? userId,
  ) async {
    await channel.invokeMethod('setUserId', {
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

    await channel.invokeMethod('setUserProperties', {
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
    await channel.invokeMethod('trackEvent', {
      'eventName': eventName,
      'eventParams': eventParams,
      'segmentationEventParamKeys': segmentationEventParamKeys,
    });
  }

  /// Registers this class as the default instance of [NotiflyFlutterPlatform]
  static void registerWith() {
    NotiflyFlutterPlatform.instance = NotiflyFlutterIOS();
  }
}
