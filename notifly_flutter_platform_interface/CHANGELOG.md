# 0.1.1

- Initial release of this plugin.

# 0.1.2

- Add compatibility with AGP <4.2

# 0.1.4

- Nullable userId in setUserId.

# 1.0.0

- Official release: Transitioned from beta to stable version.

# 1.0.1

- Android Push Notification Handling Improvement: Resolved an issue preventing URLs from opening when the app was previously opened by another push notification.

# 1.0.2

- Android Push Notification Handling Improvement: Utilized TaskStackBuilder for creating pending intents, ensuring proper navigation through app hierarchy.

# 1.0.3

- Android: Implement setLogLevel function for testing in development.

# 1.1.0

- Remove dependency on FCM for notifly in app messaging.

# 1.1.1

- Fix issue with notifly in app messaging.

# 1.1.2

- Android In-App Message: Fix background transparency issue.

# 1.1.4

- Android In-App Message: Improve stability, fix rounded corners issue. As of 1.1.3, the in-app message will be displayed only for devices of API level 30 (Red Velvet Cake) and above.

# 1.1.5

- Android: Removed material dependency.

# 1.1.6

- Android: Bumped compileSdkVersion to 33.

# 1.1.7

- iOS: Fix issue with type casting of user properties.

# 1.1.8

- In-App Message: Now in-app modals won't be dismissed when the user taps on the background by default. It is configurable via the notifly console when creating the in-app message from the template.
- In-App Message: In-app messages are now displayed after the content is available. Previously, the in-app messages were displayed even if the content was not yet available, causing the temporal white-screen issue especially when the size of the content is large.

# 1.2.0

- In-App-Messsage: Improved stability and performance.
- In-App-Messsage: Fix problems which occur when the url of main button is invalid.

# 1.2.1

- Support Web Platofrm
- ios: push-extension for rich push notification

# 1.2.2

- android: directory structure change

# 1.2.3

- ios: fix issue with push-extension
