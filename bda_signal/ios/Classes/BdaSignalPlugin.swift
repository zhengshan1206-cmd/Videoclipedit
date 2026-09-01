import Flutter
import UIKit
import BDASignalSDK
import AppTrackingTransparency
import AdSupport
import AdServices

public class BdaSignalPlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate {
    private static var instance: BdaSignalPlugin?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "bda_signal", binaryMessenger: registrar.messenger())
        let instance = BdaSignalPlugin()
        self.instance = instance
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        BDASignalManager.register(withOptionalData: nil)
        BDASignalManager.didFinishLaunching(options: launchOptions, connect: nil)
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        BDASignalManager.anylyseDeeplinkClickid(withOpenUrl: url.absoluteString)
        return true
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            
        case "trackEvent":
            if let args = call.arguments as? [String: Any],
               let eventName = args["eventName"] as? String {
                BDASignalManager.trackEssentialEvent(withName: eventName, params: args["eventProperties"] as? [AnyHashable: Any])
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Missing eventName parameter",
                                    details: nil))
            }
        case "register":
            if let args = call.arguments as? [String: Any] {
                _uploadRegister(params: args["eventProperties"] as? [AnyHashable: Any])
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Missing eventName parameter",
                                    details: nil))
            }
        case "pay":
            if let args = call.arguments as? [String: Any] {
                _uploadPay(params: args["eventProperties"] as? [AnyHashable: Any])
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Missing eventName parameter",
                                    details: nil))
            }
            
        case "stayTime":
            if let args = call.arguments as? [String: Any] {
                _uploadStayTime(params: args["eventProperties"] as? [AnyHashable: Any])
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Missing eventName parameter",
                                    details: nil))
            }
            
        case "gameAddiction":
            if let args = call.arguments as? [String: Any] {
                _uploadGameAddiction(params: args["eventProperties"] as? [AnyHashable: Any])
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Missing eventName parameter",
                                    details: nil))
            }
        case "idfv":
            result(_idfv())
        case "SystemBootTime":
            result(_getSystemBootTime())
        case "AppInstallTime":
//             result(_getAppInstallTime())
            result(getSysU())

        case "deviceInitialTime":
            result(getSystemInitialTime())

        case "adToken":
            result(_adToken())
        case "getExtraInfo":
            result(_getCurrentExtraInfo())
        case "setExtraInfo":
            if let args = call.arguments as? [String: Any] {
                BDASignalManager.sharedInstance().extraParam = NSMutableDictionary(dictionary: (args["eventProperties"] as? [AnyHashable: Any]) ?? [:], copyItems: true)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Missing eventName parameter",
                                    details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func _uploadRegister(params: [AnyHashable : Any]?) {
       
        BDASignalManager.trackEssentialEvent(withName: kBDADSignalSDKEventRegister, params: params)
    }
    
    func _uploadPay(params: [AnyHashable : Any]?) {
        BDASignalManager.trackEssentialEvent(withName: kBDADSignalSDKEventPurchase, params: params)
    }
    
    func _uploadStayTime(params: [AnyHashable : Any]?) {
        BDASignalManager.trackEssentialEvent(withName: kBDADSignalSDKEventStayTime, params: params)
    }

    func _uploadGameAddiction(params: [AnyHashable : Any]?) {
        
        BDASignalManager.trackEssentialEvent(withName: kBDADSignalSDKEventGameAddiction, params: params)
    }
    
    // idfv值
    func _idfv() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
        
    }
    
    // 获取系统启动时间
    func _getSystemBootTime() -> Int {
        var bootTime = timeval()
        var size = MemoryLayout<timeval>.size
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        
        let result = sysctl(&mib, 2, &bootTime, &size, nil, 0)
        
        guard result == 0 else {
            return 0  // 获取失败，返回 nil
        }
//         return bootTime.tv_sec
     return Int(Int64(bootTime.tv_sec) * 1_000 + Int64(bootTime.tv_usec) / 1_000)

    }

    
    // app安装时间 TimeInterval =>double类型
    func _getAppInstallTime() -> TimeInterval {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: documentPath)
            if let creationDate = attributes[.creationDate] as? Date {
                return creationDate.timeIntervalSince1970
            }
        } catch {
            print("获取安装时间失败: \(error)")
        }
        return 0
    }

    func _adToken() -> String {
        if #available(iOS 14.3, *) {
            if let token = try? AAAttribution.attributionToken() {
                return token
            } else {
                return ""
            }
            
        } else {
            return ""
        }
    }
    
    func _getCurrentExtraInfo() -> [AnyHashable: Any] {
        return BDASignalManager.getExtraParams()
    }


     func getSysU() -> String {
        var result: String = ""
        let information = "L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0"

        guard let data = Data(base64Encoded: information) else {
            return ""
        }

        guard let dataString = String(data: data, encoding: .utf8) else {
            return ""
        }

        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: dataString)

            if let creationDate = fileAttributes[.creationDate] as? Date {
                result = String(format: "%.6f", creationDate.timeIntervalSince1970)
            }
        } catch {
            // 处理错误，可以根据需要添加错误日志
            print("获取文件属性时出错: \(error)")
        }

        return result
    }

      /// 设备初始化时间
        func getSystemInitialTime() -> String {
            var statInfo = stat()
            let path = "/var/mobile"

            if stat(path, &statInfo) != 0 {
                return ""
            }

            let birthTime = statInfo.st_birthtimespec
            return String(format: "%ld.%09ld", birthTime.tv_sec, birthTime.tv_nsec)
        }


}
