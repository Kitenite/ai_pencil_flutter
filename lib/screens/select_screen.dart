import 'dart:convert';

import 'package:ai_pencil/model/drawing_layer.dart';
import 'package:ai_pencil/model/drawing_project.dart';
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
      return prefs.getStringList('projects') ?? [];
    });
  }

  void updateProjectList() async {
    SharedPreferences prefs = await _prefs;
    var projects = prefs.getStringList('projects') ?? [];
    setState(() {
      _jsonEncodedProjects =
          prefs.setStringList('projects', projects).then((bool success) {
        return projects;
      });
    });
  }

  void addProject() async {
    SharedPreferences prefs = await _prefs;
    var projects = prefs.getStringList('projects') ?? [];
    DrawingProject newProject = DrawingProject(
        title: 'Project ${projects.length + 1}', layers: [DrawingLayer()]);
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
          IconButton(
            onPressed: () {
              addProject();
            },
            icon: const Icon(FontAwesomeIcons.plus),
          )
        ],
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
        future: _jsonEncodedProjects,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: snapshot.data!.asMap().entries.map((entry) {
                int idx = entry.key;
                String jsonEncodedProject = entry.value;
                DrawingProject project =
                    DrawingProject.fromJson(json.decode(jsonEncodedProject));
                return ListTile(
                  title: Text(project.title),
                  onTap: () {
                    navigateToProject(idx, project);
                  },
                );
              }).toList(),
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
