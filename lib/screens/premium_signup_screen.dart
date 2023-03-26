import 'package:ai_pencil/utils/dialog_helper.dart';
import 'package:ai_pencil/utils/event_analytics.dart';
import 'package:flutter/material.dart';

class PremiumSignUpScreen extends StatefulWidget {
  @override
  _PremiumSignUpScreenState createState() => _PremiumSignUpScreenState();
}

class _PremiumSignUpScreenState extends State<PremiumSignUpScreen> {
  List<String> titles = [
    'Multiple image generation',
    'Disable content filters',
    'Unlock custom models',
    'High resolution images',
    'Advanced model configurations',
  ];
  List<bool> checkedList = [
    false,
    false,
    false,
    false,
    false,
  ];
  String _inputText = '';

  @override
  Widget build(BuildContext context) {
    getCheckedList() {
      List<String> checkedTitles = [];
      for (int i = 0; i < checkedList.length; i++) {
        if (checkedList[i]) {
          checkedTitles.add(titles[i]);
        }
      }
      return checkedTitles;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up to Pro'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Why do you want to sign up?',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              // For each title, create a CheckboxListTile

              for (int i = 0; i < titles.length; i++)
                CheckboxListTile(
                  title: Text(titles[i]),
                  value: checkedList[i],
                  activeColor: Colors.amber,
                  onChanged: (value) {
                    setState(() {
                      checkedList[i] = value!;
                    });
                  },
                ),

              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Other reasons',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _inputText = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Perform signup action here
                      MixPanelAnalyticsManager().trackEvent(
                        'premium_signup',
                        {
                          'reasons': getCheckedList(),
                          'other_reasons': _inputText,
                        },
                      );
                      DialogHelper.showConfirmDialog(
                        context,
                        'Thank you for signing up!',
                        'This feature is only available to a limited number of users. You are added to a wait list.',
                        'Ok',
                        '',
                        () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    child: Text('Sign Up and Pay'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
