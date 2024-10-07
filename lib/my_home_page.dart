import 'package:flutter/material.dart';
import 'package:social_share_flutter/components/facebook_share_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
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
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FacebookShareButton(),

             
            ],
          ),
        ),
      ),
    );
  }
}
