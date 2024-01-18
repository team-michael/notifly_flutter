import 'package:logger/logger.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

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

  /// Initialize Notifly Flutter.
  static Future<void> initialize({
    required String projectId,
    required String username,
    required String password,
  }) async {
    try {
      await _platform.initialize(projectId, username, password);
    } catch (e) {
      _logger.e('Failed to', e);
    }
  }

  /// Sets the user ID.
  static Future<void> setUserId(String? userId) async {
    try {
      await _platform.setUserId(userId);
    } catch (e) {
      _logger.e('Failed to', e);
    }
  }

  /// Sets the user properties.
  static Future<void> setUserProperties(Map<String, Object> params) async {
    try {
      await _platform.setUserProperties(params);
    } catch (e) {
      _logger.e('Failed to', e);
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
      _logger.e('Failed to', e);
    }
  }

  /// Sets the log level.
  static Future<void> setLogLevel(int logLevel) async {
    try {
      await _platform.setLogLevel(logLevel);
    } catch (e) {
      _logger.e('Failed to', e);
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _platform.requestPermission();
    } catch (e) {
      _logger.e('Failed to', e);
    }
  }
}
