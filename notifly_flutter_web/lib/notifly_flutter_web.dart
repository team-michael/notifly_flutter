import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:notifly_flutter_platform_interface/notifly_flutter_platform_interface.dart';

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
    final lodashScript = ScriptElement()
      ..async = true
      ..type = 'text/javascript'
      ..src = 'https://cdn.jsdelivr.net/npm/lodash@4.17.21/lodash.min.js';

    document.head!.append(lodashScript);

    final script = ScriptElement()
      ..async = true
      ..type = 'text/javascript'
      ..text = '''
      
      async function initializeNotifly() {
          const {default: notifly} = await import("https://cdn.notifly.tech/notifly-js-sdk/dist/index.js");
          await notifly.initialize({
              projectId: '$projectId', 
              username: '$username', 
              password: '$password', 
          });
          window.notifly = notifly;
      }
      
      initializeNotifly();
      async function callNotiflyMethod(command, params, callback) {
          if (!window.notifly?.[command]) {
              console.error("Notifly is not initialized yet");
              callback(false);
              return;
          }
          const parsedParams = params.map(param => JSON.parse(param));
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
}
