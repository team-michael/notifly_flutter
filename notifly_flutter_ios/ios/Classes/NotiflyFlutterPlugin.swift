import Flutter
import Foundation
import UIKit
import notifly_sdk

public class NotiflyFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var isNativeInAppMessageEventListenerAdded = false
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    print("🔧 [Plugin] Registering iOS plugin")

    let channel = FlutterMethodChannel(
      name: "notifly_flutter_ios", binaryMessenger: registrar.messenger())
    let instance = NotiflyFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Setup EventChannel for in-app message events
    let eventChannel = FlutterEventChannel(
      name: "notifly_flutter/in_app_events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    print("✅ [Plugin] EventChannel ready for in-app events")

    print("✅ [Plugin] iOS plugin registered successfully")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("🔥 [iOS] ========== handle() START ==========")
    print("🔥 [iOS] Method name: \(call.method)")
    print("🔥 [iOS] Arguments: \(String(describing: call.arguments))")
    print("🔥 [iOS] Thread: \(Thread.current)")
    
    switch call.method {
    case "getPlatformName":
      print("🔥 [iOS] Returning platform name: ios")
      result("ios")
      print("🔥 [iOS] ========== handle() COMPLETED ==========")
      return

    case "initialize":
      print("🔥 [iOS] Handling initialize() method call...")
      if let arguments = call.arguments as? [String: Any],
        let projectId = arguments["projectId"] as? String,
        let username = arguments["username"] as? String,
        let password = arguments["password"] as? String {
        print("🔥 [iOS] ========== initialize() START ==========")
        print("🔥 [iOS] ✓ Arguments parsed successfully")
        print("🔥 [iOS]   - projectId: \(projectId)")
        print("🔥 [iOS]   - username: \(username)")
        print("🔥 [iOS]   - password: \(password.isEmpty ? "empty" : "***")")
        
        print("🔥 [iOS] Step 1: Setting SDK type and version...")
        print("🔥 [iOS] SDK type: flutter")
        print("🔥 [iOS] SDK version: \(Constants.SDK_VERSION)")
        Notifly.setSdkType(type: "flutter")
        Notifly.setSdkVersion(version: Constants.SDK_VERSION)
        print("🔥 [iOS] ✓ SDK type and version set")
        
        print("🔥 [iOS] Step 2: Calling Notifly.initialize()...")
        Notifly.initialize(projectId: projectId, username: username, password: password)
        print("🔥 [iOS] ✓ Notifly.initialize() completed successfully")
        print("🔥 [iOS] ========== initialize() COMPLETED ==========")
      } else {
        print("🔥 [iOS] ✗ Invalid arguments for initialize")
        print("🔥 [iOS] Arguments type: \(type(of: call.arguments))")
        log(funcName: "initialize", message: "Invalid arguments")
      }
      result(nil)
      print("🔥 [iOS] ========== handle() COMPLETED ==========")

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
      print("🔥 [iOS] ✗ Unknown method: \(call.method)")
      result(FlutterMethodNotImplemented)
      print("🔥 [iOS] ========== handle() COMPLETED (not implemented) ==========")
    }
  }

  private func log(funcName: String, message: String) {
    print("🔥 [Notifly Error] \(funcName) Failed: \(message)")
  }
  
  // FlutterStreamHandler implementation
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    print("📡 [inAppEventListener] Stream subscribed")

    eventSink = events

    // Register native listener only once (singleton pattern for hot reload)
    if !isNativeInAppMessageEventListenerAdded {
      isNativeInAppMessageEventListenerAdded = true
      Notifly.addInAppMessageEventListener { [weak self] eventName, eventParams in
        DispatchQueue.main.async {
          do {
            // Format params for logging
            let paramsStr = eventParams?.map { "\($0.key): \($0.value)" }.joined(separator: ", ") ?? "none"
            print("🎯 [inAppEventListener] Event received: \(eventName)")
            print("📦 [inAppEventListener] Params: {\(paramsStr)}")

            guard let sink = self?.eventSink else {
              print("⚠️ [inAppEventListener] Stream not subscribed - event dropped")
              return
            }

            let payload: [String: Any] = [
              "name": eventName,
              "params": eventParams ?? [:],
              "platform": "ios",
              "ts": Int(Date().timeIntervalSince1970 * 1000)
            ]
            sink(payload)
            print("✅ [inAppEventListener] Event sent to Flutter")
          } catch {
            print("❌ [inAppEventListener] Failed to send event: \(error.localizedDescription)")
          }
        }
      }
      print("✅ [inAppEventListener] Native listener registered")
    } else {
      print("♻️ [inAppEventListener] Reusing existing listener (hot reload)")
    }

    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    print("🔕 [inAppEventListener] Stream unsubscribed")

    eventSink = nil
    // Note: We keep the native listener for hot reload support

    return nil
  }
}
