import 'package:flutter/material.dart';
import 'package:social_share_flutter/components/snack_bar_view.dart';
import 'package:social_share_flutter/events/native_call_event.dart';

class PinterestShareButton extends StatefulWidget {
  const PinterestShareButton({super.key});

  @override
  State<PinterestShareButton> createState() => _PinterestShareButtonState();
}

class _PinterestShareButtonState extends State<PinterestShareButton> {
  Future<void> linkShare() async {
    const url = 'https://stackoverflow.com/';
    String message = await NativeCallEvent.shareToPinterest(
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
            "Pinterest",
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
