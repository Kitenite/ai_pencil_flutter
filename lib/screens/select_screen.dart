import 'dart:convert';

import 'package:ai_pencil/utils/constants.dart';
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
  bool editMode = false;
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
      backgroundColor: CustomColors.canvasColor.value,
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

  void deleteProject(int idx) async {
    SharedPreferences prefs = await _prefs;
    var projects = prefs.getStringList(Constants.PROJECTS_KEY) ?? [];
    if (idx >= projects.length) {
      return;
    }
    projects.removeAt(idx);
    setState(() {
      _jsonEncodedProjects =
          prefs.setStringList('projects', projects).then((bool success) {
        return projects;
      });
    });
  }

  void renameProject(int idx, String newName) async {
    SharedPreferences prefs = await _prefs;
    var projects = prefs.getStringList(Constants.PROJECTS_KEY) ?? [];
    if (idx >= projects.length) {
      return;
    }
    var project = jsonDecode(projects[idx]);
    project['title'] = newName;
    projects[idx] = jsonEncode(project);
    setState(() {
      _jsonEncodedProjects =
          prefs.setStringList('projects', projects).then((bool success) {
        return projects;
      });
    });
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

  Widget getDeleteButton(int idx) {
    if (!editMode) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        deleteProject(idx);
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Icon(
          FontAwesomeIcons.trash,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget getRenameButton(int idx, String currentName) {
    if (!editMode) {
      return const SizedBox.shrink();
    }

    return InkWell(
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(
          FontAwesomeIcons.pen,
          size: 12,
          color: Colors.white,
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String newName = currentName;
            return AlertDialog(
              title: const Text('Rename Project'),
              content: TextField(
                autofocus: true,
                controller: TextEditingController(text: currentName),
                onChanged: (String value) {
                  newName = value;
                },
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Rename'),
                  onPressed: () {
                    renameProject(idx, newName);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
            onPressed: () {
              setState(() {
                editMode = !editMode;
              });
            },
            child: Text(editMode ? "Done" : "Edit"),
          ),
          addProjectButton
        ],
      ),
      body: FutureBuilder(
        future: _jsonEncodedProjects,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 3,
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

                      return InkWell(
                        onTap: () {
                          navigateToProject(idx, project);
                        },
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 100,
                                  maxWidth: 100,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  child: project.thumbnailImageBytes != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                          child: Image.memory(
                                            project.thumbnailImageBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          color: CustomColors.canvasColor,
                                          height: 100,
                                          width: 100,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  project.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  !editMode
                                      ? Text(
                                          "${project.aspectWidth} x ${project.aspectHeight}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  getRenameButton(idx, project.title),
                                  getDeleteButton(idx)
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                      // return ListTile(
                      //   title: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Flexible(
                      //         child: Text(
                      //           project.title,
                      //           maxLines: 2,
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //       ),
                      //       getRenameButton(idx, project.title)
                      //     ],
                      //   ),
                      //   onTap: () {
                      //     navigateToProject(idx, project);
                      //   },
                      //   trailing: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       //getRenameButton(idx, project.title),
                      //       getDeleteButton(idx)
                      //     ],
                      //   ),
                      // );
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
      ),
    );
  }
}

class SelectProjectGridItem extends StatelessWidget {
  final int idx;
  final DrawingProject project;
  const SelectProjectGridItem(
      {super.key, required this.idx, required this.project});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
