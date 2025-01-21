import 'package:flutter/services.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

/// An implementation of [NotiflyFlutterPlatform] that uses method channels.
class MethodChannelNotiflyFlutter extends NotiflyFlutterPlatform {
  /// The method channel used to interact with the native platform.
  MethodChannelNotiflyFlutter() {
    channel = const MethodChannel('notifly_flutter');
  }

  @override
  Future<String?> getPlatformName() {
    return channel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<void> initialize(String projectId, String username, String password) {
    final args = <String, dynamic>{
      'projectId': projectId,
      'username': username,
      'password': password,
    };

    return channel.invokeMethod<void>('initialize', args);
  }

  @override
  Future<void> setLogLevel(int logLevel) {
    final args = <String, dynamic>{
      'logLevel': logLevel,
    };
    return channel.invokeMethod<void>('setLogLevel', args);
  }

  @override
  Future<void> setUserId(String? userId) {
    final args = <String, dynamic>{
      'userId': userId,
    };
    return channel.invokeMethod<void>('setUserId', args);
  }

  @override
  Future<void> setUserProperties(Map<String, Object> params) {
    final args = <String, dynamic>{
      'params': params,
    };
    return channel.invokeMethod<void>('setUserProperties', args);
  }

  @override
  Future<void> setEmail(String email) {
    final args = <String, dynamic>{
      'email': email,
    };
    return channel.invokeMethod<void>('setEmail', args);
  }

  @override
  Future<void> setPhoneNumber(String phoneNumber) {
    final args = <String, dynamic>{
      'phoneNumber': phoneNumber,
    };
    return channel.invokeMethod<void>('setPhoneNumber', args);
  }

  @override
  Future<void> setTimezone(String timezone) {
    final args = <String, dynamic>{
      'timezone': timezone,
    };
    return channel.invokeMethod<void>('setTimezone', args);
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
    return channel.invokeMethod<void>('trackEvent', args);
  }

  @override
  Future<String?> getNotiflyUserId() {
    return channel.invokeMethod<String>('getNotiflyUserId');
  }

  @override
  Future<void> requestPermission() {
    return channel.invokeMethod<void>('requestPermission');
  }
}
