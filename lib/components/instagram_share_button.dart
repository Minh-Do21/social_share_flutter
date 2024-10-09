import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_share_flutter/components/snack_bar_view.dart';
import 'package:social_share_flutter/events/native_call_event.dart';

class InstagramShareButton extends StatefulWidget {
  const InstagramShareButton({super.key});

  @override
  State<InstagramShareButton> createState() => _InstagramShareButtonState();
}

class _InstagramShareButtonState extends State<InstagramShareButton> {

  Future<void> pickImageAndShare() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      final message = await NativeCallEvent.shareToInstagram(
        imagePath: imagePath,
      );

      // ignore: use_build_context_synchronously
      SnackBarView.show(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Instagram",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 40),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
            elevation: WidgetStateProperty.all(0),
          ),
          onPressed: () async {
            pickImageAndShare();
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
