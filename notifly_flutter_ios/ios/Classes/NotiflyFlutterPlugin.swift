import Flutter
import Foundation
import UIKit
import notifly_sdk

public class NotiflyFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var isNativeInAppMessageEventListenerAdded = false
  
  public static func register(with registrar: FlutterPluginRegistrar) {
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
      result(FlutterMethodNotImplemented)
    }
  }

  private func log(funcName: String, message: String) {
    print("🔥 [Notifly Error] \(funcName) Failed: \(message)")
  }
  
  // FlutterStreamHandler implementation
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    
    // Register native listener only once (singleton pattern for hot reload)
    if !isNativeInAppMessageEventListenerAdded {
      isNativeInAppMessageEventListenerAdded = true
      Notifly.addInAppMessageEventListener { [weak self] eventName, eventParams in
        DispatchQueue.main.async {
          do {
            let payload: [String: Any] = [
              "name": eventName,
              "params": eventParams ?? [:],
              "platform": "ios",
              "ts": Int(Date().timeIntervalSince1970 * 1000)
            ]
            self?.eventSink?(payload)
          } catch {
            // Silently fail, just log (following existing pattern)
            print("🔥 [Notifly Error] Failed to send in-app event: \(error)")
          }
        }
      }
    }
    
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    // Note: We don't remove the native listener here to support hot reload
    // The listener will be reused if the stream is re-subscribed
    return nil
  }
}
