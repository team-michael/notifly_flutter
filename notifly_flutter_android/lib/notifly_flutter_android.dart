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
  Future<void> initialize(
    String projectId,
    String username,
    String password,
  ) async {
    final args = <String, dynamic>{
      'projectId': projectId,
      'username': username,
      'password': password,
    };

    final success = await methodChannel.invokeMethod<bool>('initialize', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'INITIALIZATION_FAILED',
        message: 'Initialization failed',
      );
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    final args = <String, dynamic>{
      'userId': userId,
    };

    final success = await methodChannel.invokeMethod<bool>('setUserId', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'SET_USER_ID_FAILED',
        message: 'Setting user ID failed',
      );
    }
  }

  @override
  Future<void> setUserProperties(Map<String, Object> params) async {
    final args = <String, dynamic>{
      'params': params,
    };

    final success =
        await methodChannel.invokeMethod<bool>('setUserProperties', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'SET_USER_PROPERTIES_FAILED',
        message: 'Setting user properties failed',
      );
    }
  }

  @override
  Future<void> trackEvent(
    String eventName,
    Map<String, Object>? eventParams,
    List<String>? segmentationEventParamKeys,
  ) async {
    final args = <String, dynamic>{
      'eventName': eventName,
      'eventParams': eventParams,
      'segmentationEventParamKeys': segmentationEventParamKeys,
    };

    final success = await methodChannel.invokeMethod<bool>('trackEvent', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'TRACK_EVENT_FAILED',
        message: 'Tracking event failed',
      );
    }
  }
}
