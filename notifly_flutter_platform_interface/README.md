# notifly_flutter_platform_interface

[![Pub](https://img.shields.io/pub/v/notifly_flutter_platform_interface.svg)](https://pub.dev/packages/notifly_flutter_platform_interface)

A common platform interface for the `notifly_flutter` plugin.

This interface allows platform-specific implementations of the `notifly_flutter` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## Usage

To implement a new platform-specific implementation of `notifly_flutter`, extend `NotiflyFlutterPlatform` with an implementation that performs the platform-specific behavior.
