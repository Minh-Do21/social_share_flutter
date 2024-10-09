import Flutter
import FBSDKShareKit
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
      let controller = window?.rootViewController as! FlutterViewController
          let shareChannel = FlutterMethodChannel(name: "com.example.social_share_flutter",binaryMessenger: controller.binaryMessenger)
          
      shareChannel.setMethodCallHandler { (call, result) in
             if call.method == "shareToFacebook" {
                 let args = call.arguments as! [String: Any]
                 
                 // Sử dụng ép kiểu an toàn cho các trường optional
                 let url = args["url"] as? String
                 let imagePath = args["imagePath"] as? String
                         
                 self.shareImageAndLinkOnFacebook(viewController: controller, imagePath: imagePath, url: url, result: result)

             }else {
                 result(FlutterMethodNotImplemented)
             }
         }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func shareImageAndLinkOnFacebook(viewController: UIViewController, imagePath: String?, url: String?, result: @escaping FlutterResult) {
        
        var image: UIImage? = nil
            
            // Kiểm tra nếu có imagePath và tải ảnh từ đường dẫn
            if let path = imagePath {
                if let loadedImage = UIImage(contentsOfFile: path) {
                    image = loadedImage
                } else {
                    result(FlutterError(code: "FILE_NOT_FOUND", message: "Image file not found", details: nil))
                    return
                }
            }
            
            // Nếu không có hình ảnh và URL cũng không có, trả về lỗi
            if image == nil && url == nil {
                result(FlutterError(code: "NO_CONTENT", message: "No image or URL to share", details: nil))
                return
            }

            // Nếu chỉ có URL và không có hình ảnh
            if image == nil, let urlString = url, let contentURL = URL(string: urlString) {
                let content = ShareLinkContent()
                content.contentURL = contentURL

                // Hiển thị dialog chia sẻ
                let dialog = ShareDialog(viewController: viewController, content: content, delegate: nil)
                
                if dialog.canShow {
                    dialog.show()
                    result("Share dialog shown")
                } else {
                    result(FlutterError(code: "UNAVAILABLE", message: "Cannot show share dialog", details: nil))
                }
                return
            }
            
            // Nếu có hình ảnh và có thể có URL
            let content = SharePhotoContent()
            if let validImage = image {
                let sharePhoto = SharePhoto(image: validImage, isUserGenerated: true)
                content.photos = [sharePhoto]
            }
            
            if let urlString = url, let contentURL = URL(string: urlString) {
                content.contentURL = contentURL
            }
            
            // Hiển thị dialog chia sẻ
            let dialog = ShareDialog(viewController: viewController, content: content, delegate: nil)
            
            if dialog.canShow {
                dialog.show()
                result("Share dialog shown")
            } else {
                result(FlutterError(code: "UNAVAILABLE", message: "Cannot show share dialog", details: nil))
            }
    }
}
