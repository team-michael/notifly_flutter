import 'package:notifly_flutter/src/utils.dart';

/// Represents an in-app message event received from the Notifly service.
class InAppMessageEvent extends JSONStringRepresentable {
  /// Constructs a new instance of [InAppMessageEvent] from the given map.
  factory InAppMessageEvent.fromMap(Map<String, dynamic> map) {
    return InAppMessageEvent(
      name: map['name'] as String,
      params: map['params'] != null
          ? Map<String, dynamic>.from(map['params'] as Map)
          : null,
      platform: map['platform'] as String? ?? 'unknown',
      timestampMillis: map['ts'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Constructs a new instance of [InAppMessageEvent].
  InAppMessageEvent({
    required this.name,
    this.params,
    required this.platform,
    required this.timestampMillis,
  });

  /// The name of the event (e.g., 'main_button_click', 'close_button_click').
  final String name;

  /// The parameters of the event (nullable).
  final Map<String, dynamic>? params;

  /// The platform where the event occurred ('android' | 'ios').
  final String platform;

  /// The timestamp when the event occurred in milliseconds since epoch.
  final int timestampMillis;

  @override
  String jsonRepresentation() {
    return convertToJsonString({
      'name': name,
      'params': params,
      'platform': platform,
      'ts': timestampMillis,
    });
  }
}

