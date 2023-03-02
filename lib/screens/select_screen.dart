import 'dart:convert';

import 'package:ai_pencil/constants.dart';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/model/drawing/aspect_ratio.dart';
import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/screens/draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectProjectScreen extends StatefulWidget {
  const SelectProjectScreen({super.key});

  @override
  State<SelectProjectScreen> createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends State<SelectProjectScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<List<String>> _jsonEncodedProjects;

  @override
  void initState() {
    super.initState();
    _jsonEncodedProjects = _prefs.then((SharedPreferences prefs) {
      return prefs.getStringList(Constants.PROJECTS_KEY) ?? [];
    });
  }

  void updateProjectList() async {
    SharedPreferences prefs = await _prefs;
    var projects = prefs.getStringList(Constants.PROJECTS_KEY) ?? [];
    setState(() {
      _jsonEncodedProjects = prefs
          .setStringList(Constants.PROJECTS_KEY, projects)
          .then((bool success) {
        return projects;
      });
    });
  }

  void addProject(double aspectWidth, double aspectHeight) async {
    SharedPreferences prefs = await _prefs;
    var projects = prefs.getStringList(Constants.PROJECTS_KEY) ?? [];
    DrawingProject newProject = DrawingProject(
      title: 'Project ${projects.length + 1}',
      layers: [DrawingLayer()],
      aspectHeight: aspectHeight,
      aspectWidth: aspectWidth,
      advancedOptions: AdvancedOptions(),
    );
    projects.add(jsonEncode(newProject.toJson()));
    setState(() {
      _jsonEncodedProjects =
          prefs.setStringList('projects', projects).then((bool success) {
        return projects;
      });
    });
    navigateToProject(projects.length - 1, newProject);
  }

  void navigateToProject(int idx, DrawingProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrawScreen(
          project: project,
          projectIndex: idx,
        ),
      ),
    ).then((_) {
      // Update projects after returning from draw screen
      updateProjectList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var addProjectButton = PopupMenuButton<DrawingAspectRatio>(
      initialValue: null,
      icon: const Icon(FontAwesomeIcons.plus),
      onSelected: (DrawingAspectRatio item) {
        switch (item) {
          case DrawingAspectRatio.square:
            addProject(1, 1);
            break;
          case DrawingAspectRatio.twoByThree:
            addProject(2, 3);
            break;
          case DrawingAspectRatio.threeByFour:
            addProject(3, 4);
            break;
          case DrawingAspectRatio.nineBySixteen:
            addProject(9, 16);
            break;
          case DrawingAspectRatio.threeByTwo:
            addProject(3, 2);
            break;
          case DrawingAspectRatio.fourByThree:
            addProject(4, 3);
            break;
          case DrawingAspectRatio.sixteenByNine:
            addProject(16, 9);
            break;
          case DrawingAspectRatio.screenSize:
            addProject(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<DrawingAspectRatio>>[
        const PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.square,
          child: Text('Square (1x1)'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.twoByThree,
          child: Text('Portrait (2x3)'),
        ),
        const PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.threeByFour,
          child: Text('Portrait (3x4)'),
        ),
        const PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.nineBySixteen,
          child: Text('Portrait (9x16)'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.threeByTwo,
          child: Text('Landscape (3x2)'),
        ),
        const PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.fourByThree,
          child: Text('Landscape (4x3)'),
        ),
        const PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.sixteenByNine,
          child: Text('Landscape (16x9)'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<DrawingAspectRatio>(
          value: DrawingAspectRatio.screenSize,
          child: Text(
              'Screen size (${MediaQuery.of(context).size.width}x${MediaQuery.of(context).size.height})'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ai Pencil",
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Select"),
          ),
          addProjectButton
        ],
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
        future: _jsonEncodedProjects,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: snapshot.data!
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      int idx = entry.key;
                      String jsonEncodedProject = entry.value;
                      DrawingProject project = DrawingProject.fromJson(
                        json.decode(jsonEncodedProject),
                      );
                      return ListTile(
                        title: Text(project.title),
                        onTap: () {
                          navigateToProject(idx, project);
                        },
                      );
                    },
                  )
                  .toList()
                  .reversed
                  .toList(),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      )),
    );
  }
}
