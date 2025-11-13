import Flutter
import Foundation
import UIKit
import notifly_sdk

public class NotiflyFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  // Static variables shared across all instances (singleton pattern for hot reload)
  private static var sharedEventSink: FlutterEventSink?
  private static var isNativeInAppMessageEventListenerAdded = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Defensive check for registrar validity
    guard registrar.messenger() != nil else {
      print("❌ [Notifly] Plugin attach failed: registrar.messenger() is nil")
      fatalError("Failed to register Notifly plugin: messenger is nil")
    }

    let channel = FlutterMethodChannel(
      name: "notifly_flutter_ios", binaryMessenger: registrar.messenger())
    let instance = NotiflyFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Setup EventChannel for in-app message events
    let eventChannel = FlutterEventChannel(
      name: "notifly_flutter/in_app_events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformName":
      result("ios")

    case "initialize":
      if let arguments = call.arguments as? [String: Any],
        let projectId = arguments["projectId"] as? String,
        let username = arguments["username"] as? String,
        let password = arguments["password"] as? String {

        Notifly.setSdkType(type: "flutter")
        Notifly.setSdkVersion(version: Constants.SDK_VERSION)
        Notifly.initialize(projectId: projectId, username: username, password: password)

        print("🚀 [Notifly] Initialized (project: \(projectId))")
      } else {
        log(funcName: "initialize", message: "Invalid arguments")
      }
      result(nil)

    case "setUserId":
      if let arguments = call.arguments as? [String: Any] {
        let userId = arguments["userId"] as? String
        Notifly.setUserId(userId: userId)
      } else {
        log(funcName: "setUserId", message: "Invalid arguments")
      }
      result(nil)

    case "setUserProperties":
      if let arguments = call.arguments as? [String: Any],
        let userProperties = arguments["userProperties"] as? String,
        let parsedUserProperties = NotiflyAnyCodable.parseJsonString(userProperties) {
        Notifly.setUserProperties(userProperties: parsedUserProperties)
      } else {
        log(funcName: "setUserProperties", message: "Invalid arguments")
      }
      result(nil)

    case "setEmail":
      if let arguments = call.arguments as? [String: Any] {
        guard let email = arguments["email"] as? String else {
          log(funcName: "setEmail", message: "Email is required")
          result(nil)
          return
        }
        Notifly.setEmail(email)
      } else {
        log(funcName: "setEmail", message: "Invalid arguments")
      }
      result(nil)

    case "setPhoneNumber":
      if let arguments = call.arguments as? [String: Any] {
        guard let phoneNumber = arguments["phoneNumber"] as? String else {
          log(funcName: "setPhoneNumber", message: "Phone number is required")
          result(nil)
          return
        }
        Notifly.setPhoneNumber(phoneNumber)
      } else {
        log(funcName: "setPhoneNumber", message: "Invalid arguments")
      }
      result(nil)

    case "setTimezone":
      if let arguments = call.arguments as? [String: Any] {
        guard let timezone = arguments["timezone"] as? String else {
          log(funcName: "setTimezone", message: "Timezone is required")
          result(nil)
          return
        }
        Notifly.setTimezone(timezone)
      } else {
        log(funcName: "setTimezone", message: "Invalid arguments")
      }
      result(nil)

    case "trackEvent":
      if let arguments = call.arguments as? [String: Any],
        let eventName = arguments["eventName"] as? String {
        let segmentationEventParamKeys = arguments["segmentationEventParamKeys"] as? [String]
        if let eventParams = arguments["eventParams"] as? String,
           let parsedEventParams = NotiflyAnyCodable.parseJsonString(eventParams) {
            Notifly.trackEvent(
            eventName: eventName, eventParams: parsedEventParams,
            segmentationEventParamKeys: segmentationEventParamKeys)
        } else {
          Notifly.trackEvent(
            eventName: eventName, eventParams: nil,
            segmentationEventParamKeys: segmentationEventParamKeys)
        }
      } else {
        log(funcName: "trackEvent", message: "Invalid arguments")
      }
      result(nil)

    case "getNotiflyUserId":
      let notiflyUserId = Notifly.getNotiflyUserId()
      if notiflyUserId != nil {
        result(notiflyUserId)
      } else {
        result(nil)
      }

    default:
      print("⚠️ [Notifly] Unknown method: \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }

  private func log(funcName: String, message: String) {
    print("❌ [Notifly] \(funcName) failed: \(message)")
  }
  
  // FlutterStreamHandler implementation
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    print("📡 [Notifly] InApp stream subscribed")

    // Defensive check for EventSink validity
    guard events != nil else {
      print("❌ [Notifly] Failed to subscribe: EventSink is nil")
      return FlutterError(
        code: "SUBSCRIBE_FAILED",
        message: "Failed to subscribe to in-app events",
        details: "EventSink is nil"
      )
    }

    NotiflyFlutterPlugin.sharedEventSink = events

    // Register native listener only once (singleton pattern for hot reload)
    if !NotiflyFlutterPlugin.isNativeInAppMessageEventListenerAdded {
      NotiflyFlutterPlugin.isNativeInAppMessageEventListenerAdded = true
      Notifly.addInAppMessageEventListener { eventName, eventParams in
        DispatchQueue.main.async {
          print("📨 [Notifly] Event: \(eventName)")

          guard let sink = NotiflyFlutterPlugin.sharedEventSink else {
              print("⚠️ [Notifly] Event dropped (no subscription)")
              return
            }

          let sanitizedParams = (eventParams as Any?) ?? NSNull()

          let payload: [String: Any] = [
            "eventName": eventName,
            "eventParams": sanitizedParams
          ]

          sink(payload)
        }
      }
      print("📡 [Notifly] InApp listener registered")
    } else {
      print("♻️ [Notifly] Reusing existing listener")
    }

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    print("🔌 [Notifly] InApp stream unsubscribed")

    NotiflyFlutterPlugin.sharedEventSink = nil
    // Note: We keep the native listener for hot reload support

    return nil
  }
}
