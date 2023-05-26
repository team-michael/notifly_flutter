# notifly_flutter

[![Pub](https://img.shields.io/pub/v/notifly_flutter.svg)](https://pub.dev/packages/notifly_flutter)
![coverage][coverage_badge]

[coverage_badge]: notifly_flutter/coverage_badge.svg

## Local test

Open `notifly_flutter/example` in Android Studio, and run the flutter example app.

## Release

### 1. Bump version

TODO: make a script for updating versions.

Update in the following files:

- notifly_flutter/pubspec.yaml (`version`)
- notifly_flutter_android/pubspec.yaml (`version`)
- notifly_flutter_ios/pubspec.yaml (`version`)
- notifly_flutter_platform_interface/pubspec.yaml (`version`)
- notifly_flutter_android/.../version.kt (`NOTIFLY_FLUTTER_PLUGIN_VERSION`)
- notifly_flutter_ios/.../version.swift (`SDK_VERSION`)

Update CHANGELOG.md in each directories:

```
notifly_flutter_platform_interface/CHANGELOG.md
notifly_flutter_ios/CHANGELOG.md
notifly_flutter_android/CHANGELOG.md
notifly_flutter/CHANGELOG.md
```

### 2. Publish

TODO: make a script for dry-run publishing.
TODO: make a script for publishing.

Publish in the subdirectories, in the following order:

```
notifly_flutter_platform_interface
notifly_flutter_ios
notifly_flutter_android
notifly_flutter
```

run in each subdirectory:

```
flutter pub publish
```
