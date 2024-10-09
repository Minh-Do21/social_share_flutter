import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_share_flutter/components/snack_bar_view.dart';
import 'package:social_share_flutter/events/native_call_event.dart';

class LineShareButton extends StatefulWidget {
  const LineShareButton({super.key});

  @override
  State<LineShareButton> createState() => _LineShareButtonState();
}

class _LineShareButtonState extends State<LineShareButton> {
  bool isImageShare = true;

  @override
  void initState() {
    super.initState();
    if(Platform.isIOS){
      setState(() {
        isImageShare = false;
      });
    }
  }

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
      final message = await NativeCallEvent.shareToLine(
        imagePath: imagePath,
      );

      // ignore: use_build_context_synchronously
      SnackBarView.show(context, message);
    }
  }

  Future<void> linkShare() async {
    const url = 'https://www.google.com';
    final message = await NativeCallEvent.shareToLine(
      url: url,
    );

    // ignore: use_build_context_synchronously
    SnackBarView.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Line",
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
            if (Platform.isAndroid) {
              setState(() {
                isImageShare = value;
              });
            }else{
              SnackBarView.show(context, 'Line app on ios only allows sharing url.');
            }
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
            // shareToLine('https://www.google.com', null);
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
