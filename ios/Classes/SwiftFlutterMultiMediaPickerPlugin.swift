import Flutter
import UIKit
import Photos

public class SwiftFlutterMultiMediaPickerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fullter_multimedia_picker", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterMultiMediaPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
                case "getAll":
                    DispatchQueue(label: "getAll").async {
                        let imagesVideos = FileFetcher.getAllPhotosVideos()
                        let encodedData = try? JSONEncoder().encode(imagesVideos)
                        let json = String(data: encodedData!, encoding: .utf8)!
                        result(json)
                    }
                case "getImage":
                    DispatchQueue(label: "getImage").async {
                        let photos = FileFetcher.getImage()
                        let encodedData = try? JSONEncoder().encode(photos)
                        let json = String(data: encodedData!, encoding: .utf8)!
                        result(json)
                    }
                case "getVideo":
                    DispatchQueue(label: "getVideo").async {
                        let photos = FileFetcher.getVideo()
                        let encodedData = try? JSONEncoder().encode(photos)
                        let json = String(data: encodedData!, encoding: .utf8)!
                        result(json)
                    }
                case "getThumbnail":
                    guard let fileId = (call.arguments as? Dictionary<String, Any>)?["fileId"] as? String else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "fileId must not be null", details: nil))
                        return
                    }
                    guard let type = (call.arguments as? Dictionary<String, Any>)?["type"] as? Int else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "type must not be null", details: nil))
                        return
                    }
                    DispatchQueue(label: "getThumbnail").async {
                        let thumbnail = FileFetcher.getThumbnail(for: fileId, type: MediaType.init(rawValue: type)!)
                        if (thumbnail != nil) {
                            result(thumbnail)
                        } else {
                            result(FlutterError(code: "NOT_FOUND", message: "Unable to get the thumbnail", details: nil))
                        }
                    }
                case "getMediaFile":
                    guard let fileId = (call.arguments as? Dictionary<String, Any>)?["fileId"] as? String else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "fileId must not be null", details: nil))
                        return
                    }
                     guard let type = (call.arguments as? Dictionary<String, Any>)?["type"] as? Int else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "type must not be null", details: nil))
                        return
                    }
                    DispatchQueue(label: "getMediaFile").async {
                        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [fileId], options: .none).firstObject
                        if asset == nil {
                            result(FlutterError(code: "NOT_FOUND", message: "Unable to get the file", details: nil))
                            return
                        }
                        let mediaFile = FileFetcher.getMediaFile(for: asset!, loadPath: true, generateThumbnailIfNotFound: true)
                        if (mediaFile != nil) {
                            let encodedData = try? JSONEncoder().encode(mediaFile)
                            let json = String(data: encodedData!, encoding: .utf8)!
                            result(json)
                        } else {
                            result(FlutterError(code: "NOT_FOUND", message: "Unable to get the file", details: nil))
                        }
                    }
                default:
                    result(FlutterError.init(
                        code: "NOT_IMPLEMENTED",
                        message: "Unknown method:  \(call.method)",
                        details: nil))
                }

            }
  }
