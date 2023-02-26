import 'package:ai_pencil/drawing_canvas/utils/image_helpers.dart';
import 'package:ai_pencil/model/drawing_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InferenceScreen extends HookWidget {
  final DrawingProject project;
  final GlobalKey canvasGlobalKey;

  const InferenceScreen({
    super.key,
    required this.project,
    required this.canvasGlobalKey,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageToImageTab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Text(
                "Enhance your drawing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FutureBuilder(
                future: ImageHelper.getCanvasImage(canvasGlobalKey),
                builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "Describe your image",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const TextField(
              autocorrect: true,
              maxLines: null,
              maxLength: 350,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Be as descriptive as you can',
              ),
            ),
            OutlinedButton(
              onPressed: () {},
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
                  "Generate Image",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );

    Widget textToImageTab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 15, top: 10),
              child: Text(
                "Create art from text",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            const TextField(
              autocorrect: true,
              maxLines: null,
              maxLength: 350,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Be as descriptive as you can',
              ),
            ),
            OutlinedButton(
              onPressed: () {},
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
                  "Generate Image",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );

    Widget inpaintingTab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Text(
                "Edit your image",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Text(
                "Inpainting, outpainting, resizing and upscaling. (Coming soon)."),
          ],
        ),
      ),
    );

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(),
          body: TabBarView(
            children: [
              imageToImageTab,
              textToImageTab,
              inpaintingTab,
            ],
          ),
          bottomNavigationBar: const TabBar(
            indicatorColor: Colors.amber,
            tabs: [
              Tab(icon: Icon(FontAwesomeIcons.image)),
              Tab(icon: Icon(FontAwesomeIcons.comment)),
              Tab(icon: Icon(FontAwesomeIcons.wandMagicSparkles)),
            ],
          ),
        ),
      ),
    );
  }
}
