import 'package:ai_pencil/utils/dialog_helper.dart';
import 'package:ai_pencil/utils/event_analytics.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:ai_pencil/utils/snackbar.dart';
import 'package:ai_pencil/utils/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class InferenceCompleteScreen extends HookWidget {
  final Uint8List imageBytes;
  final String prompt;
  final Function(Uint8List, String? title) onAddImageAsLayer;
  final Function(Uint8List) onRetryInference;

  const InferenceCompleteScreen({
    Key? key,
    required this.imageBytes,
    required this.prompt,
    required this.onAddImageAsLayer,
    required this.onRetryInference,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(text: prompt);

    void onBackButtonPressed() {
      DialogHelper.showConfirmDialog(
          context,
          "Discard drawing?",
          "This will discard your drawing and leave the page.",
          "Discard",
          "Cancel", () {
        MixPanelAnalyticsManager().trackEvent("Discard inference", {});
        Navigator.pop(context);
      });
    }

    void onDownloadImageButtonPressed() {
      try {
        MixPanelAnalyticsManager()
            .trackEvent("Download inference to device", {});
        ImageHelper.saveFile(imageBytes, ".png");
        SnackBarHelper.showSnackBar(context, "Image saved!");
      } catch (e) {
        MixPanelAnalyticsManager()
            .trackEvent("Download image to device failed", {});
        DialogHelper.showInfoDialog(context, "Failed to download image",
            "Please allow access to photos.", "OK");
      }
    }

    void onAddToProjectButtonPressed() {
      MixPanelAnalyticsManager().trackEvent("Add inference to project", {});
      onAddImageAsLayer(imageBytes, textController.value.text);
      Navigator.pop(context);
    }

    void onRetryInferenceButtonPressed() {
      DialogHelper.showConfirmDialog(
          context,
          "Retry generation?",
          "This will discard your drawing and generate a new one.",
          "Confirm",
          "Cancel", () {
        // TODO: Retry navigation
        onRetryInference(imageBytes);
        Navigator.pop(context);
      });
    }

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: onBackButtonPressed,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.memory(imageBytes),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Text(
                  "Name your image",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 10.0),
                child: TextField(
                  controller: textController,
                  autocorrect: true,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Drawing name placeholder',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // IconButton(
                    //   icon: const Icon(
                    //     FontAwesomeIcons.rotateLeft,
                    //     color: Colors.white,
                    //   ),
                    //   onPressed: onRetryInferenceButtonPressed,
                    // ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.white,
                      ),
                      onPressed: onBackButtonPressed,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.download,
                        color: Colors.white,
                      ),
                      onPressed: onDownloadImageButtonPressed,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onAddToProjectButtonPressed,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(
                    color: CustomTheme.primaryColor,
                    width: 1,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Add to Project",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ));
  }
}
