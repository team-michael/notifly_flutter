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
  /// Initialize Notifly Flutter.
  Future<bool> initialize(
      String projectId, String username, String password,) async {
    // Invoke the platform-specific method.
    final success = await _platform.initialize(projectId, username, password);

    if (!success) throw Exception('Unable to initialize Notifly Flutter.');
    return success;
  }
}
