import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

NotiflyFlutterPlatform get _platform => NotiflyFlutterPlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}
