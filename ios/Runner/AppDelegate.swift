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
          let shareChannel = FlutterMethodChannel(name: "com.example.share",
                                                  binaryMessenger: controller.binaryMessenger)
          
      shareChannel.setMethodCallHandler { (call, result) in
             if call.method == "shareLinkOnFacebook" {
                 let args = call.arguments as! [String: Any]
                 let url = args["url"] as! String
                 let description = args["description"] as! String
                 let imagePath = args["imagePath"] as! String
                 
                 
                 var images = [UIImage]()
                         
                         for path in [imagePath] {
                             if let image = UIImage(contentsOfFile: path) {
                                 images.append(image)
                             } else {
                                 result(FlutterError(code: "FILE_NOT_FOUND", message: "Image file not found", details: nil))
                                 return
                             }
                         }
                 
                 self.shareImageAndLinkOnFacebook(viewController: controller, images: images, url: url, result: result)

             } else {
                 result(FlutterMethodNotImplemented)
             }
         }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func shareImageAndLinkOnFacebook(viewController: UIViewController, images: [UIImage], url: String, result: @escaping FlutterResult) {
        
        
        // Tạo đối tượng SharePhoto từ mỗi UIImage trong danh sách
            let sharePhotos = images.map { SharePhoto(image: $0, isUserGenerated: true) }

            // Tạo nội dung SharePhotoContent
            let photoContent = SharePhotoContent()
            photoContent.photos = sharePhotos

            // Tạo nội dung ShareLinkContent
//            let linkContent = ShareLinkContent()
//            linkContent.contentURL = URL(string: url)!

            // Tạo nội dung ShareMediaContent để kết hợp cả ảnh và URL
//            let content = ShareMediaContent()
//            content.media = sharePhotos
//            content.hashtag = Hashtag("#"+url)
//            content.ref = "ABC"
        
//        let content = ShareLinkContent()
//        content.contentURL = URL(string: url)!
        
        
        let content = SharePhotoContent()
                content.photos = sharePhotos
                content.hashtag = Hashtag("#YourHashtag \(url)") // Optional hashtag
   
                
                // Bạn có thể thêm URL vào mô tả nếu cần
//                content.contentURL = URL(string: url)!


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
