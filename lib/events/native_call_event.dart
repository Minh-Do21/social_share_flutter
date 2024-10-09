import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NativeCallEvent {
  static const platform = MethodChannel('com.example.social_share_flutter');

  static Future<void> shareToFacebook({String? url, String? imagePath}) async {
    try {
      await platform.invokeMethod(
        'shareToFacebook',
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

  static Future<String> shareToInstagram({
    required String imagePath,
  }) async {
    try {
      if (await File(imagePath).exists()) {
        if (Platform.isIOS) {
          final uri = Uri.file(imagePath);
          final instagramUri =
              'instagram://library?LocalIdentifier=${uri.path}';

          if (await canLaunchUrl(Uri.parse(instagramUri))) {
            await launchUrl(Uri.parse(instagramUri));
            return 'Sharing to Instagram successful';
          } else {
            return 'Instagram not installed';
          }
        } else {
          try {
            final String result = await platform.invokeMethod(
              'shareToInstagramFeed',
              {
                'imagePath': imagePath,
              },
            );
            return result;
          } on PlatformException catch (e) {
            return e.message ?? '';
          }
        }
      } else {
        return 'Image file not found at path: $imagePath';
      }
    } catch (e) {
      return 'Error sharing to Instagram: $e';
    }
  }

  static Future<String> shareToLine({String? url, String? imagePath}) async {
    try {
      if (Platform.isAndroid) {
        final String result = await platform.invokeMethod(
          'shareToLine',
          {
            'url': url,
            'imagePath': imagePath,
          },
        );
        return result;
      } else {
        String lineUrl = "line://msg/text/";

        // Nếu có URL, mã hóa và thêm vào
        if (url != null && url.isNotEmpty) {
          final encodedUrl = Uri.encodeComponent(url);
          lineUrl += encodedUrl;
        }

        // Kiểm tra xem có thể mở URL không
        if (await canLaunchUrlString(lineUrl)) {
          await launchUrlString(lineUrl);
          return 'Sharing to Line successful';
        } else {
          return 'Line not installed';
        }
      }
    } on PlatformException catch (e) {
      return e.message ?? '';
    }
  }

  static Future<String> shareToTwitter({String? url, String? imagePath}) async {
    try {
      String tweetUrl = 'twitter://post?message=$url';

      if (await canLaunchUrlString(tweetUrl)) {
        await launchUrlString(tweetUrl);
        return 'Sharing to Twitter successful';
      } else {
        return 'Twitter not installed';
      }
    } catch (e) {
      return 'Error sharing to Instagram: $e';
    }
  }

  static Future<String> shareToPinterest({String? url}) async {
    if (Platform.isAndroid) {
      try {
        final String result = await platform.invokeMethod(
          'shareToPinterest',
          {
            'url': url,
          },
        );
        return result;
      } on PlatformException catch (e) {
        return e.message ?? '';
      }
    } else {
      try {
        final pinterestUrl = "https://www.pinterest.com/pin/create/link/?url=$url";

        if (await canLaunchUrlString(pinterestUrl)) {
          await launchUrlString(pinterestUrl);
          return 'Sharing to Twitter successful';
        } else {
          return 'Twitter not installed';
        }
      } catch (e) {
        return 'Error sharing to Instagram: $e';
      }
    }
  }
}
