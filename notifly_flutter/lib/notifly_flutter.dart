import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:notifly_flutter/src/notification.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

export 'package:notifly_flutter/src/notification.dart';

NotiflyFlutterPlatform get _platform => NotiflyFlutterPlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

/// Notifly Flutter plugin.
class NotiflyPlugin {
  static final _logger = Logger();

  static bool _isInitialized = false;
  static final _notificationClickListeners = <NotificationClickListener>{};
  static bool _isClickListenerRegistered = false;

  /// Initialize Notifly Flutter.
  static Future<void> initialize({
    required String projectId,
    required String username,
    required String password,
  }) async {
    try {
      if (!_isInitialized) {
        if (!kIsWeb && Platform.isAndroid) {
          // Currently only Android platform requires method call handler.
          _platform.channel.setMethodCallHandler(_handleMethodCall);
        }
        await _platform.initialize(projectId, username, password);
        _isInitialized = true;
      } else {
        _logger.w('Notifly Flutter is already initialized.');
      }
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Requests web push permission. Only works on web.
  static Future<void> requestPermission() async {
    if (kIsWeb) {
      try {
        await _platform.requestPermission();
      } catch (e) {
        _logger.e('Failed to', error: e);
      }
    } else {
      _logger.w('This method is only available on web.');
    }
  }

  /// Sets the log level.
  static Future<void> setLogLevel(int logLevel) async {
    try {
      await _platform.setLogLevel(logLevel);
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Sets the user ID.
  static Future<void> setUserId(String? userId) async {
    try {
      await _platform.setUserId(userId);
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Sets the user properties.
  static Future<void> setUserProperties(Map<String, Object> params) async {
    try {
      await _platform.setUserProperties(params);
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Sets the email for the current user.
  static Future<void> setEmail(String email) async {
    try {
      await _platform.setEmail(email);
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Sets the phone number for the current user.
  static Future<void> setPhoneNumber(String phoneNumber) async {
    try {
      await _platform.setPhoneNumber(phoneNumber);
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Sets the timezone for the current user.
  static Future<void> setTimezone(String timezone) async {
    try {
      await _platform.setTimezone(timezone);
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Track an event.
  static Future<void> trackEvent({
    required String eventName,
    Map<String, Object>? eventParams,
    List<String>? segmentationEventParamKeys,
  }) async {
    try {
      await _platform.trackEvent(
        eventName,
        eventParams,
        segmentationEventParamKeys,
      );
    } catch (e) {
      _logger.e('Failed to', error: e);
    }
  }

  /// Returns the Notifly user ID for the current user.
  static Future<String?> getNotiflyUserId() async {
    try {
      return await _platform.getNotiflyUserId();
    } catch (e) {
      _logger.e('Failed to', error: e);
      return null;
    }
  }

  /// Add notification click listener (Supported for Android platform only).
  static Future<void> addNotificationClickListener(
    NotificationClickListener listener,
  ) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        if (!_isClickListenerRegistered) {
          final success = await _platform.channel
              .invokeMethod<bool>('addNotificationClickListener');
          if (success == null || !success) {
            _logger.e('Failed to add notification click listener');
          }
          _isClickListenerRegistered = true;
        }
        _notificationClickListeners.add(listener);
      } catch (e) {
        _logger.e('Failed to', error: e);
      }
    } else {
      _logger.w('This method is only available on Android. '
          'For iOS, use FCM message handler instead.');
    }
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onNotificationClick') {
      final notification = Map<String, dynamic>.from(call.arguments as Map);
      for (final listener in _notificationClickListeners) {
        listener(OSNotificationClickEvent(notification));
      }
    }
  }
}
