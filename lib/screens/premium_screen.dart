// stateless widget
import 'package:ai_pencil/screens/premium_signup_screen.dart';
import 'package:ai_pencil/utils/dialog_helper.dart';
import 'package:ai_pencil/utils/event_analytics.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Color featureTextColor = Color.fromARGB(255, 198, 198, 198);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                )
              ]),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Subscribe to',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pro',
                      style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.help_outline),
                        color: Colors.white,
                        onPressed: () {
                          DialogHelper.showInfoDialog(
                              context,
                              "Pro feature details",
                              "Multiple image generation: Generate up to 4 concurrent images in one request.\n\nContent filters: Allow for NSFW contents. You will need to verify age first.\n\nCustom models: Access to communnity based models trained on image sets from anime to photo-realistic to 3D, etc.\n\nHigh resolution image: Allow for upscaling images up to 2048 x 2048 dimensions.\n\nAdvanced configurations: Unlock parameters such as steps, model strength, sampler, seed, etc.\n\nCharged monthly. You can cancel anytime.",
                              "Ok");
                        },
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 16.0),
                          child: Text(
                            'Pro features',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  '\u2022 Multiple image generation',
                                  style: TextStyle(
                                    color: featureTextColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  '\u2022 Remove content filter (18+)',
                                  style: TextStyle(
                                    color: featureTextColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  '\u2022 Unlock custom models',
                                  style: TextStyle(
                                    color: featureTextColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  '\u2022 High resolution images',
                                  style: TextStyle(
                                    color: featureTextColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  '\u2022 Advanced model configurations',
                                  style: TextStyle(
                                    color: featureTextColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 20.0),
                          child: Text(
                            '\$10/month',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 16.0),
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implement sign-up functionality.
                              MixPanelAnalyticsManager()
                                  .trackEvent('Begin subscription flow', {});
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PremiumSignUpScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.amber),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Sign up for 1 month',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),

                        // Test
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
