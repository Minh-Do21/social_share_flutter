import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_share_flutter/events/native_call_event.dart';

class FacebookShareButton extends StatefulWidget {
  const FacebookShareButton({super.key});

  @override
  State<FacebookShareButton> createState() => _FacebookShareButtonState();
}

class _FacebookShareButtonState extends State<FacebookShareButton> {
  bool isImageShare = true;

  final WidgetStateProperty<Icon?> thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return const Icon(
          Icons.image,
          color: Colors.green,
        );
      }
      return const Icon(
        Icons.link_sharp,
        color: Colors.white,
      );
    },
  );

  Future<void> pickImageAndShare() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      await NativeCallEvent.shareToFacebook(
        imagePath: imagePath,
      );
    }
  }

  Future<void> linkShare() async {
    const url = 'https://www.google.com';
    await NativeCallEvent.shareToFacebook(
      url: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Facebook",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 40),
        Switch.adaptive(
          thumbIcon: thumbIcon,
          activeColor: Colors.white,
          activeTrackColor: Colors.grey,
          inactiveThumbColor: Colors.blueAccent,
          inactiveTrackColor: Colors.grey,
          applyCupertinoTheme: false,
          value: isImageShare,
          onChanged: (bool value) {
            setState(() {
              isImageShare = value;
            });
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
            elevation: WidgetStateProperty.all(0),
          ),
          
          onPressed: () async {
            if (isImageShare) {
              pickImageAndShare();
            } else {
              linkShare();
            }
          },
          child: const Icon(
            Icons.open_in_browser_outlined,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
