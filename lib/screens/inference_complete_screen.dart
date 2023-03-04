import 'package:flutter/material.dart';

class InferenceCompleteScreen extends StatelessWidget {
  // final Uint8List imageBytes;
  const InferenceCompleteScreen({
    Key? key,
    // required this.imageBytes,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () {
            // TODO: Alert discard image
            Navigator.pop(context);
          }),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              // child: Image.memory(imageBytes),
              child: Placeholder(),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Text(
                "Name your drawing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                // controller: textController,
                autocorrect: true,
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Drawing name placeholder',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Retry"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Discard"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Download"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Add to Drawing"),
            )
          ],
        ));
  }
}
