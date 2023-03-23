import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
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
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(
                        'https://apps.apple.com/us/app/ai-pencil/id6446209407'));
                  }, // Image tapped
                  splashColor: Colors.white10, // Splash color over image
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage(
                        'assets/landing/appstore.png',
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(
                        'https://play.google.com/store/apps/details?id=io.aipencil'));
                  }, // Image tapped
                  splashColor: Colors.white10, // Splash color over image
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage(
                        'assets/landing/googleplay.png',
                      ),
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
