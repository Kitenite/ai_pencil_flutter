import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InferenceCompleteScreen extends HookWidget {
  // final Uint8List imageBytes;
  const InferenceCompleteScreen({
    Key? key,
    // required this.imageBytes,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () {
            // TODO: Alert discard image
            Navigator.pop(context);
          }),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(40.0),
                // child: Image.memory(imageBytes),
                child: Placeholder(),
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
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.rotateLeft,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Retry image generation
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Delete image and return
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.download,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Download image to device
                      },
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  // TODO: Add to image layer
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: const BorderSide(
                    color: Colors.amber,
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
