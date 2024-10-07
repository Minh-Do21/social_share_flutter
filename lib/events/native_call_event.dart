import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeCallEvent {
  static const platform = MethodChannel('com.example.social_share_flutter');

  static Future<void> shareToFacebook(
      {String? url, String? imagePath}) async {
    try {
      await platform.invokeMethod(
        'shareLinkOnFacebook',
        {
          'url': url,
          'imagePath': imagePath,
        },
      );
      debugPrint('----- Share Facebook success');
    } catch (e) {
      debugPrint('----- Error sharing to Facebook: $e');
    }
  }
}
