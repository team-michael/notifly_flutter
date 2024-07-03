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

# 1.2.4

- android: fix issue with invocation misordering between `setUserId` and `setUserProperties`

# 1.3.0

- web: support method for requesting permission
- android: bump Android SDK version from 1.3.2 to 1.4.0
- ios: bump iOS SDK version from 1.3.0 to 1.3.2

# 1.3.1

- ios: bump iOS SDK version from 1.3.2 to 1.4.0

# 1.3.2

- web: remove unnecessary log

# 1.3.3

- web: remove unnecessary log

# 1.3.4

- web: bump Web SDK version from 2.7.4 to 2.7.5

# 1.3.5

- web: make `initialize` method asynchronous

# 1.3.6

- android: Separate notification channels based on the importance of the notification
- android: Importance of the notification is now determined by the imp field in the push notification data payload
- web: bump Web SDK version from 2.7.5 to 2.7.8

# 1.3.7

- android: fix issue with app restart when the push notification is clicked on foreground state.

# 1.4.0

- android: Bump Android native SDK version from 1.4.3 to 1.5.0
  - Lots of improvements for push notification feature.
    - Application lifecycle listeners are added to avoid redundant session start logging.
    - Application lifecycle listeners are added to avoid redundant fetching of user states.
  - Push notification click event handler interface is added to allow developers to customize push
    notification click events.
  - Okhttp3 dependency is now removed from the SDK.
  - Proguard rules and consumer proguard rules are re-organized to avoid unexpected behavior.

# 1.5.0

- ios: bump iOS SDK version from 1.4.0 to 1.7.0
- add privacy manifest

# 1.5.1-rc1

- Downgrade minimum required dart sdk version to 2.12.0

# 1.6.0

- THIS VERSION IS PROBLEMETIC FOR IOS PLATFORM. PLEASE DO NOT USE THIS VERSION!!!

# 1.7.0

- Downgrade minimum required dart sdk version to 2.12.0
- Use Android Native SDK version to 1.6.0
- Use iOS Native SDK version to 1.9.0

# 1.8.0

- Downgrade minimum required dart sdk version to 2.12.0
- Now SDK automatically tracks the current timezone configuration of device
- Introducing new methods: `setEmail`, `setPhoneNumber`, `setTimezone`

# 1.8.2

- Use iOS Native SDK version 1.10.1

# 1.9.0

- Use Android Native SDK version 1.8.0
- Use iOS Native SDK version 1.13.0
