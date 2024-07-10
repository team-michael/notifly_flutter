import Flutter
import Foundation
import UIKit
import notifly_sdk

public class NotiflyFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "notifly_flutter_ios", binaryMessenger: registrar.messenger())
    let instance = NotiflyFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
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

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func log(funcName: String, message: String) {
    print("🔥 [Notifly Error] \(funcName) Failed: \(message)")
  }
}
