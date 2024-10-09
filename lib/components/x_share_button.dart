import 'package:flutter/material.dart';
import 'package:social_share_flutter/components/snack_bar_view.dart';
import 'package:social_share_flutter/events/native_call_event.dart';

class XShareButton extends StatefulWidget {
  const XShareButton({super.key});

  @override
  State<XShareButton> createState() => _XShareButtonState();
}

class _XShareButtonState extends State<XShareButton> {
  Future<void> linkShare() async {
    const url = 'https://www.google.com';
    String message = await NativeCallEvent.shareToTwitter(
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
            "X (Twitter)",
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
            linkShare();
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
