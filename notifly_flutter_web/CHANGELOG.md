# 1.2.1

Initial release

# 1.2.2

- android: directory structure change

# 1.2.3

- ios: fix issue with push-extension

# 1.2.4

- web: change method for importing javascript file from CDN
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
