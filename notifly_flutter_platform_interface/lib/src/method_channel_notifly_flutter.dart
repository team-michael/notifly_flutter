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

  @override
  Future<void> initialize(String projectId, String username, String password) {
    final args = <String, dynamic>{
      'projectId': projectId,
      'username': username,
      'password': password,
    };

    return methodChannel.invokeMethod<void>('initialize', args);
  }

  @override
  Future<void> setUserId(String userId) {
    final args = <String, dynamic>{
      'userId': userId,
    };
    return methodChannel.invokeMethod<void>('setUserId', args);
  }

  @override
  Future<void> setUserProperties(Map<String, Object> params) {
    final args = <String, dynamic>{
      'params': params,
    };
    return methodChannel.invokeMethod<void>('setUserProperties', args);
  }

  @override
  Future<void> trackEvent(
    String eventName,
    Map<String, Object>? eventParams,
    List<String>? segmentationEventParamKeys,
  ) {
    final args = <String, dynamic>{
      'eventName': eventName,
      'eventParams': eventParams,
      'segmentationEventParamKeys': segmentationEventParamKeys,
    };
    return methodChannel.invokeMethod<void>('trackEvent', args);
  }
}
