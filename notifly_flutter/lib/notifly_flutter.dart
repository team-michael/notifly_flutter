import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:notifly_flutter/src/in_app_message.dart';
import 'package:notifly_flutter/src/notification.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

export 'package:notifly_flutter/src/in_app_message.dart';
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

  // In-app message event stream
  static const _inAppEventChannel = EventChannel('notifly_flutter/in_app_events');
  static final _inAppEventsController = StreamController<InAppMessageEvent>.broadcast();
  static bool _inAppEventsWired = false;

  /// Stream of in-app message events.
  /// 
  /// This stream provides events from in-app popups such as:
  /// - `in_app_message_show`: In-app popup displayed
  /// - `main_button_click`: Main button clicked
  /// - `hide_in_app_message_button_click`: "Don't show again" button clicked
  /// - `close_button_click`: Close button clicked
  /// - `survey_submit_button_click`: Survey submit button clicked
  /// 
  /// **Note**: This stream is only available on Android and iOS platforms.
  /// Web platform is not supported.
  /// 
  /// **Usage**:
  /// ```dart
  /// NotiflyPlugin.inAppEvents.listen((event) {
  ///   print('Event: ${event.eventName}, Params: ${event.eventParams}');
  /// });
  /// ```
  /// 
  /// **Important**: Make sure to cancel the subscription when done:
  /// ```dart
  /// final subscription = NotiflyPlugin.inAppEvents.listen((event) { ... });
  /// // Later...
  /// subscription.cancel();
  /// ```
  static Stream<InAppMessageEvent> get inAppEvents {
    if (!_isInitialized) {
      throw StateError(
        'NotiflyPlugin.initialize() must be called before accessing inAppEvents. '
        'Please call NotiflyPlugin.initialize() first.'
      );
    }
    return _inAppEventsController.stream;
  }

  /// Initialize Notifly Flutter.
  static Future<void> initialize({
    required String projectId,
    required String username,
    required String password,
  }) async {
    try {
      if (!_isInitialized) {
        if (!kIsWeb && Platform.isAndroid) {
          _platform.channel.setMethodCallHandler(_handleMethodCall);
        }

        await _platform.initialize(projectId, username, password);
        _wireInAppEvents();

        _isInitialized = true;
        _logger.i('🚀 [Notifly] Initialized (project: $projectId)');
      } else {
        _logger.w('⚠️ [Notifly] Flutter is already initialized - skipping');
      }
    } catch (e, stackTrace) {
      _logger.e('❌ [Notifly] Initialization failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Wires the in-app events EventChannel to the stream controller.
  /// This is called automatically during initialization.
  static void _wireInAppEvents() {
    if (kIsWeb) {
      return;
    }

    if (_inAppEventsWired) {
      return;
    }

    try {
      final stream = _inAppEventChannel.receiveBroadcastStream();

      stream.listen(
        (dynamic event) {
          try {
            if (event is Map) {
              final eventMap = Map<String, dynamic>.from(event);
              final inAppEvent = InAppMessageEvent.fromMap(eventMap);

              _logger.i('📨 [Notifly] Event: ${inAppEvent.eventName}');
              _inAppEventsController.add(inAppEvent);
            } else {
              _logger.w('⚠️ [Notifly] Event dropped (invalid format)');
            }
          } catch (e, stackTrace) {
            _logger.e('❌ [Notifly] Failed to process event', error: e, stackTrace: stackTrace);
          }
        },
        onError: (error, stackTrace) {
          _logger.e('❌ [Notifly] EventChannel error', error: error, stackTrace: stackTrace);
        },
        cancelOnError: false,
      );

      _inAppEventsWired = true;
      _logger.i('📡 [Notifly] InApp listener ready');
    } catch (e, stackTrace) {
      _logger.e('❌ [Notifly] Failed to connect EventChannel', error: e, stackTrace: stackTrace);
      rethrow;
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
