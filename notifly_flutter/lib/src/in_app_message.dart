import 'package:notifly_flutter/src/utils.dart';

/// Represents an in-app message event received from the Notifly service.
/// This matches the native SDK interface structure exactly.
class InAppMessageEvent extends JSONStringRepresentable {
  /// Constructs a new instance of [InAppMessageEvent] from the given map.
  factory InAppMessageEvent.fromMap(Map<String, dynamic> map) {
    return InAppMessageEvent(
      eventName: map['eventName'] as String,
      eventParams: map['eventParams'] != null
          ? Map<String, dynamic>.from(map['eventParams'] as Map)
          : null,
    );
  }

  /// Constructs a new instance of [InAppMessageEvent].
  InAppMessageEvent({
    required this.eventName,
    this.eventParams,
  });

  /// The name of the event (e.g., 'main_button_click', 'close_button_click').
  final String eventName;

  /// The parameters of the event (nullable).
  /// Contains native SDK event parameters such as:
  /// - type: "message_event"
  /// - channel: "in-app-message"
  /// - campaign_id: Campaign identifier
  /// - notifly_message_id: Message identifier
  /// - button_name: Button name for click events
  /// - link: URL for main button clicks (optional)
  /// - template_name: Template name for show events (optional)
  /// - hide_until_data: Hide configuration (optional)
  /// - notifly_extra_data: Survey data (optional)
  final Map<String, dynamic>? eventParams;

  @override
  String jsonRepresentation() {
    return convertToJsonString({
      'eventName': eventName,
      'eventParams': eventParams,
    });
  }
}

