import Flutter
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
         let projectID = arguments["projectID"] as? String,
         let username = arguments["username"] as? String,
         let password = arguments["password"] as? String
      {
        Notifly.setSdkType(type: SdkType.flutter.rawValue) // TODO: REMOVE RAWVALUE
        Notifly.setSdkVersion(version: "0.0.1") // TODO: Get version from pubspec.yaml
        Notifly.initialize(projectID: projectID, username: username, password: password)
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
         let userProperties = arguments["userProperties"] as? [String: Any]
      {
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
