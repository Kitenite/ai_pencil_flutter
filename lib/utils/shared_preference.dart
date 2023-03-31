import 'dart:convert';

import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static late final SharedPreferences _prefs;

  static Future<SharedPreferences> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static int getInferenceCount() {
    int counter = 0;
    counter = _prefs.getInt(SharedPreferenceKeys.INFERENCES_COUNT) ?? 0;
    return counter;
  }

  static Future<bool> setInferenceCount(int counter) {
    return _prefs.setInt(SharedPreferenceKeys.INFERENCES_COUNT, counter);
  }

  static Future<bool> setPromptStyles(String promptStyles) {
    return _prefs.setString(SharedPreferenceKeys.PROMPT_STYLES, promptStyles);
  }

  static Future<List<String>> getProjects() async {
    return _prefs.getStringList('projects') ?? [];
  }

  static Future<bool> setProjects(
    List<String> projects,
  ) async {
    return _prefs.setStringList(SharedPreferenceKeys.PROJECTS, projects);
  }

  static Future<bool> addProjectToIndex(
    int projectIndex,
    DrawingProject updatedProject,
  ) async {
    var projects = _prefs.getStringList('projects') ?? [];
    projects[projectIndex] = jsonEncode(updatedProject.toJson());
    return _prefs.setStringList(SharedPreferenceKeys.PROJECTS, projects);
  }
}
