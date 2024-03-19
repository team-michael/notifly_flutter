import 'package:flutter/services.dart';
import 'package:notifly_flutter_platform_interface/src/method_channel_notifly_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of notifly_flutter must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `NotiflyFlutter`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken
///  by newly added [NotiflyFlutterPlatform] methods.
abstract class NotiflyFlutterPlatform extends PlatformInterface {
  /// Constructs a NotiflyFlutterPlatform.
  NotiflyFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static NotiflyFlutterPlatform _instance = MethodChannelNotiflyFlutter();

  /// The method channel used to interact with the native platform.
  late MethodChannel channel;

  /// The default instance of [NotiflyFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelNotiflyFlutter].
  static NotiflyFlutterPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [NotiflyFlutterPlatform] when they register themselves.
  static set instance(NotiflyFlutterPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();

  /// Initialize Notifly Flutter.
  Future<void> initialize(String projectId, String username, String password) {
    throw UnimplementedError();
  }

  /// Set log level for development.
  Future<void> setLogLevel(int logLevel) {
    throw UnimplementedError();
  }

  /// Sets the user ID.
  Future<void> setUserId(String? userId) {
    throw UnimplementedError();
  }

  /// Sets the user properties.
  Future<void> setUserProperties(Map<String, Object> params) {
    throw UnimplementedError();
  }

  /// Track an event.
  Future<void> trackEvent(
    String eventName,
    Map<String, Object>? eventParams,
    List<String>? segmentationEventParamKeys,
  ) {
    throw UnimplementedError();
  }

  /// Requests web push permission. Only works on web.
  Future<void> requestPermission() {
    throw UnimplementedError();
  }
}
