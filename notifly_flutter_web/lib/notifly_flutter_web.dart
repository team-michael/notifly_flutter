// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

// Project imports:
import 'constants.dart' as NOTIFLY_CONSTANTS;

/// The implementation of [NotiflyFlutterPlatform].
class NotiflyFlutterWeb extends NotiflyFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('notifly_flutter_web');

  /// Registers this class as the default instance of [NotiflyFlutterPlatform]
  static void registerWith(Registrar registrar) {
    NotiflyFlutterPlatform.instance = NotiflyFlutterWeb();
  }

  @override
  Future<String?> getPlatformName() {
    return Future.value('web');
  }

  @override
  Future<void> initialize(
    String projectId,
    String username,
    String password,
  ) async {
    final completer = Completer<void>();
    final script = ScriptElement()
      ..async = true
      ..type = 'text/javascript'
      ..text = '''
      (function (w, d, p, u, a) {
        var s = d.createElement('script');
        s.async = !0;
        s.src = 'https://cdn.jsdelivr.net/npm/${NOTIFLY_CONSTANTS.Config.JS_SDK_DEPENDENCY}/dist/index.global.min.js';
        s.onload = function () {
            w.notifly.setSdkType('${NOTIFLY_CONSTANTS.Config.SDK_TYPE}');
            w.notifly.setSdkVersion('${NOTIFLY_CONSTANTS.Config.SDK_VERSION}');
            w.notifly.initialize({ projectId: p, username: u, password: a });
            w.dispatchEvent(new CustomEvent('notiflyLoaded'));
        };
        s.onerror = function () {
            console.error('Failed to load Notifly Browser SDK.');
        };
        d.getElementsByTagName('head')[0].appendChild(s);
      })(
        window,
        document,
        '$projectId',
        '$username',
        '$password',
      );
      
      async function callNotiflyMethod(command, params = [], callback) {
          if (!window.notifly?.[command]) {
              console.error("Notifly is not initialized yet");
              callback(false);
              return;
          }
          const parsedParams = params ? params.map(param => JSON.parse(param)) : [];
          try {
            const result = await window.notifly[command](...parsedParams);
          } catch(err) {
              console.error(err);
              callback(false);
              return;
          }
          callback(true);
      }
    ''';
    document.head!.append(script);
    await window.on['notiflyLoaded'].first.then((_) => completer.complete());
    return completer.future;
  }

  @override
  Future<void> setUserId(String? userId) async {
    final completer = Completer<void>();
    js.context.callMethod('callNotiflyMethod', [
      'setUserId',
      js.JsArray.from([jsonEncode(userId)]),
      js.allowInterop((bool suc) {
        if (suc == true) {
          completer.complete();
        } else {
          completer.completeError('Failed to set user id');
        }
      }),
    ]);
    return completer.future;
  }

  @override
  Future<void> setUserProperties(Map<String, Object> params) async {
    final completer = Completer<void>();
    js.context.callMethod('callNotiflyMethod', [
      'setUserProperties',
      js.JsArray.from([jsonEncode(params)]),
      js.allowInterop((bool suc) {
        if (suc == true) {
          completer.complete();
        } else {
          completer.completeError('Failed to set user properties');
        }
      }),
    ]);
    return completer.future;
  }

  @override
  Future<void> trackEvent(
    String eventName,
    Map<String, Object>? eventParams,
    List<String>? segmentationEventParamKeys,
  ) async {
    final completer = Completer<void>();
    js.context.callMethod('callNotiflyMethod', [
      'trackEvent',
      js.JsArray.from([
        jsonEncode(eventName),
        jsonEncode(eventParams),
        jsonEncode(segmentationEventParamKeys),
      ]),
      js.allowInterop((bool suc) {
        if (suc == true) {
          completer.complete();
        } else {
          completer.completeError('Failed to track event');
        }
      }),
    ]);
    return completer.future;
  }

  @override
  Future<void> requestPermission() async {
    final completer = Completer<void>();
    js.context.callMethod('callNotiflyMethod', [
      'requestPermission',
      null,
      js.allowInterop((bool suc) {
        if (suc == true) {
          completer.complete();
        } else {
          completer.completeError('Failed to request permission');
        }
      }),
    ]);
    return completer.future;
  }
}
