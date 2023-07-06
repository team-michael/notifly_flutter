import Flutter
import Foundation
import notifly_sdk
import UIKit

public class NotiflyFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "notifly_flutter_ios", binaryMessenger: registrar.messenger())
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
         let password = arguments["password"] as? String
      {
        Notifly.setSdkType(type: SdkType.flutter.rawValue)
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
         var userProperties = arguments["userProperties"] as? [String: Any],
         let typeMap = arguments["typeMap"] as? [String: String]
      {
        for (key, value) in typeMap {
          switch value {
          case "int":
            if let intValue = userProperties[key] as? Int {
              userProperties[key] = intValue
            }
          case "bool":
            if let boolValue = userProperties[key] as? Bool {
              userProperties[key] = boolValue
            }
          default:
            continue
          }
        }
        Notifly.setUserProperties(userProperties: userProperties)
      } else {
        log(funcName: "setUserProperties", message: "Invalid arguments")
      }
      result(nil)

    case "trackEvent":
      if let arguments = call.arguments as? [String: Any],
         let eventName = arguments["eventName"] as? String
      {
        let eventParams = arguments["eventParams"] as? [String: Any]
        let segmentationEventParamKeys = arguments["segmentationEventParamKeys"] as? [String]
        Notifly.trackEvent(eventName: eventName, eventParams: eventParams, segmentationEventParamKeys: segmentationEventParamKeys)
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
