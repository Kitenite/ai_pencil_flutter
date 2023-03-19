import 'package:flutter/material.dart';
import 'dart:js' as js;

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Image(
                  width: 150,
                  height: 150,
                  image: AssetImage(
                    'assets/landing/icon.png',
                  ),
                ),
                Text(
                  'Pencil',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    js.context.callMethod('open', [
                      'https://apps.apple.com/us/app/ai-pencil-lite/id6444737491'
                    ]);
                  }, // Image tapped
                  splashColor: Colors.white10, // Splash color over image
                  child: const Image(
                    image: AssetImage(
                      'assets/landing/appstore.png',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    js.context.callMethod('open', [
                      'https://play.google.com/store/apps/details?id=io.aipencil'
                    ]);
                  }, // Image tapped
                  splashColor: Colors.white10, // Splash color over image
                  child: const Image(
                    image: AssetImage(
                      'assets/landing/googleplay.png',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
