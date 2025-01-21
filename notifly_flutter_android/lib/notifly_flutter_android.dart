import 'package:flutter/services.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

/// The Android implementation of [NotiflyFlutterPlatform].
class NotiflyFlutterAndroid extends NotiflyFlutterPlatform {
  /// Creates a new instance of [NotiflyFlutterAndroid].
  NotiflyFlutterAndroid() {
    channel = const MethodChannel('notifly_flutter_android');
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
    final args = <String, dynamic>{
      'projectId': projectId,
      'username': username,
      'password': password,
    };

    final success = await channel.invokeMethod<bool>('initialize', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'INITIALIZATION_FAILED',
        message: 'Initialization failed',
      );
    }
  }

  @override
  Future<void> setLogLevel(int logLevel) async {
    final args = <String, dynamic>{
      'logLevel': logLevel,
    };

    final success = await channel.invokeMethod<bool>('setLogLevel', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'SET_LOG_LEVEL_FAILED',
        message: 'Setting log level failed',
      );
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    final args = <String, dynamic>{
      'userId': userId,
    };

    final success = await channel.invokeMethod<bool>('setUserId', args);
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

    final success = await channel.invokeMethod<bool>('setUserProperties', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'SET_USER_PROPERTIES_FAILED',
        message: 'Setting user properties failed',
      );
    }
  }

  @override
  Future<void> setEmail(String email) async {
    final args = <String, dynamic>{
      'email': email,
    };

    final success = await channel.invokeMethod<bool>('setEmail', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'SET_EMAIL_FAILED',
        message: 'Setting email failed',
      );
    }
  }

  @override
  Future<void> setPhoneNumber(String phoneNumber) async {
    final args = <String, dynamic>{
      'phoneNumber': phoneNumber,
    };

    final success = await channel.invokeMethod<bool>('setPhoneNumber', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'SET_PHONE_NUMBER_FAILED',
        message: 'Setting phone number failed',
      );
    }
  }

  @override
  Future<void> setTimezone(String timezone) async {
    final args = <String, dynamic>{
      'timezone': timezone,
    };

    final success = await channel.invokeMethod<bool>('setTimezone', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'SET_TIMEZONE_FAILED',
        message: 'Setting timezone failed',
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

    final success = await channel.invokeMethod<bool>('trackEvent', args);
    if (success == null || !success) {
      throw PlatformException(
        code: 'TRACK_EVENT_FAILED',
        message: 'Tracking event failed',
      );
    }
  }

  @override
  Future<String?> getNotiflyUserId() async {
    return channel.invokeMethod<String>('getNotiflyUserId');
  }

  /// Registers this class as the default instance of [NotiflyFlutterPlatform]
  static void registerWith() {
    NotiflyFlutterPlatform.instance = NotiflyFlutterAndroid();
  }
}
