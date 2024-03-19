import 'dart:convert';

import 'package:notifly_flutter/src/utils.dart';

/// Callback for handling received notifications.
typedef NotificationClickListener = void Function(
  OSNotificationClickEvent event,
);

/// Represents the importance of a notification. (Used only on Android)
enum OSNotificationImportance {
  /// The notification is of low importance.
  low,

  /// The notification is of normal importance.
  normal,

  /// The notification is of high importance.
  high,
}

/// Represents a notification received from the Notifly service.
class OSNotification extends JSONStringRepresentable {
  /// Constructs a new instance of [OSNotification] from the given
  /// JSON representation.
  OSNotification(Map<String, dynamic> json) {
    notiflyMessageId = json['notiflyMessageId'] as String?;
    androidNotificationId = json['androidNotificationId'] as int?;
    campaignId = json['campaignId'] as String?;
    title = json['title'] as String?;
    body = json['body'] as String?;
    importance = json.containsKey('importance')
        ? OSNotificationImportance.values[
            json['importance'] as int? ?? OSNotificationImportance.normal.index]
        : null;
    url = json['url'] as String?;
    imageUrl = json['imageUrl'] as String?;
    sentTime = json['sentTime'] as int?;
    ttl = json['ttl'] as int?;
    customData = json['customData'] != null
        ? Map<String, dynamic>.from(json['customData'] as Map)
        : null;

    // raw payload comes as a JSON string
    if (json.containsKey('rawPayload')) {
      final raw = json['rawPayload'] as String;
      const decoder = JsonDecoder();
      rawPayload = decoder.convert(raw) as Map<String, dynamic>;
    }
  }

  /// The Notifly message ID of the notification.
  String? notiflyMessageId;

  /// (Only Android) The Android system notification ID of the notification.
  int? androidNotificationId;

  /// Notifly campaign ID where the notification was sent from.
  String? campaignId;

  /// Notification title
  String? title;

  /// Notification body
  String? body;

  /// (Only Android) Importance of the notification.
  OSNotificationImportance? importance;

  /// URL included in the notification.
  String? url;

  /// URL to the image included in the notification.
  String? imageUrl;

  /// Sent time of the notification in milliseconds since epoch
  int? sentTime;

  /// TTL of the notification in seconds
  int? ttl;

  /// Customized data included in the notification.
  Map<String, dynamic>? customData;

  /// Raw payload of the notification.
  Map<String, dynamic>? rawPayload;

  @override
  String jsonRepresentation() => convertToJsonString(rawPayload);
}

/// Represents a notification click event.
class OSNotificationClickEvent extends JSONStringRepresentable {
  /// Constructs a new instance of [OSNotificationClickEvent] from the given
  OSNotificationClickEvent(Map<String, dynamic> json) {
    notification =
        OSNotification(Map<String, dynamic>.from(json['notification'] as Map));
  }

  /// The notification that was clicked.
  late OSNotification notification;

  @override
  String jsonRepresentation() {
    return convertToJsonString({
      'notification': notification.jsonRepresentation(),
    });
  }
}
