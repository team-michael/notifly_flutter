import 'dart:convert';
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
    final stringifiedParams = jsonEncode(params);
    await channel.invokeMethod('setUserProperties', {
      'userProperties': stringifiedParams,
    });
  }

  @override
  Future<void> setEmail(String email) async {
    await channel.invokeMethod('setEmail', {
      'email': email,
    });
  }

  @override
  Future<void> setPhoneNumber(String phoneNumber) async {
    await channel.invokeMethod('setPhoneNumber', {
      'phoneNumber': phoneNumber,
    });
  }

  @override
  Future<void> setTimezone(String timezone) async {
    await channel.invokeMethod('setTimezone', {
      'timezone': timezone,
    });
  }

  @override
  Future<void> trackEvent(
    String eventName,
    Map<String, Object>? eventParams,
    List<String>? segmentationEventParamKeys,
  ) async {
    final stringifiedParams =
        eventParams == null ? null : jsonEncode(eventParams);

    await channel.invokeMethod('trackEvent', {
      'eventName': eventName,
      'eventParams': stringifiedParams,
      'segmentationEventParamKeys': segmentationEventParamKeys,
    });
  }

  /// Registers this class as the default instance of [NotiflyFlutterPlatform]
  static void registerWith() {
    NotiflyFlutterPlatform.instance = NotiflyFlutterIOS();
  }
}
