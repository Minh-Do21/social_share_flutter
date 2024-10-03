import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = '122222222222';
  String subject = 'Minh DOooooooooo';
  String uri = '';
  String fileName = '';
  List<String> imageNames = [];
  List<String> imagePaths = [];

  static const platform = MethodChannel('com.example.share');

  @override
  void initState() {
    super.initState();
  }

  // void shareLinkOnFacebook() async {
  //   final result = await FacebookAuth.instance.login(); // Đăng nhập Facebook

  //   if (result.status == LoginStatus.success) {
  //     // Người dùng đã đăng nhập thành công
  //     final accessToken = result.accessToken;

  //     // Gọi đến Facebook Share Dialog thay vì URL trực tiếp
  //     final success = await FacebookAuth.instance.shareLink(
  //       quote: "Check out this awesome link!",
  //       link: Uri.parse('https://flutter.dev'),
  //     );

  //     if (success) {
  //       print('Share successful');
  //     } else {
  //       print('Share failed');
  //     }
  //   } else {
  //     print('Facebook login failed');
  //   }
  // }

  Future<void> pickImageAndShare() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      shareLinkOnFacebook(
          'https://example.com', 'My post description', imagePath);
    }
  }

  void shareLinkOnFacebook(
      String url, String description, String imagePath) async {
    try {

      final result = await platform.invokeMethod('shareLinkOnFacebook', {
        'url': url,
        'description': description,
        'imagePath': imagePath, // Đường dẫn file ảnh
      });
      print(result);
    } catch (e) {
      print('Error sharing to Facebook: $e');
    }
  }

  void shareToFacebook() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final box = context.findRenderObject() as RenderBox?;

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
    final shareResult = await Share.shareXFiles(
      [pickedFile],
      subject: subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,

      // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
    }

    // final shareResult = await Share.shareXFiles(
    //     text,
    //     subject: subject,
    //     // sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    //   );

    //  final facebookAppUrl = 'fb://facewebmodal/f?href=$url'; // Mở ứng dụng Facebook

    // final facebookWebUrl = 'https://www.facebook.com/sharer/sharer.php?u=$url';

    // if (await canLaunch(facebookAppUrl)) {
    //   await launch(facebookAppUrl);
    // } else {
    //   await launch(facebookWebUrl);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Share'),
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Faceboook",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 40),
                  ElevatedButton(
                    child: Icon(Icons.gradient),
                    onPressed: () async {
                      pickImageAndShare();
                      // shareToFacebook('https://droptip.jp/l');
                      // shareToFacebook();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Share result: ${result.status}"),
          if (result.status == ShareResultStatus.success)
            Text("Shared to: ${result.raw}")
        ],
      ),
    );
  }
}
