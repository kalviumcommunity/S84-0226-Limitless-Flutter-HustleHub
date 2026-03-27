import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustlehub/models/task_model.dart';
import 'package:hustlehub/providers/projects_provider.dart';

class TasksProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      _tasks = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String projectId, String title, ProjectsProvider projectsProvider) async {
    try {
      final newTask = TaskModel(
        id: '',
        projectId: projectId,
        title: title,
        createdAt: DateTime.now(),
      );

      final docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .add(newTask.toMap());
      
      final addedTask = TaskModel(
        id: docRef.id,
        projectId: projectId,
        title: title,
        createdAt: DateTime.now(),
      );
      
      _tasks.insert(0, addedTask);
      
      _updateProjectProgress(projectId, projectsProvider);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding task: $e");
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(String projectId, String taskId, bool newStatus, ProjectsProvider projectsProvider) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': newStatus});

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final t = _tasks[index];
        _tasks[index] = TaskModel(
          id: t.id,
          projectId: t.projectId,
          title: t.title,
          isCompleted: newStatus,
          createdAt: t.createdAt,
        );
        _updateProjectProgress(projectId, projectsProvider);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating task: $e");
      rethrow;
    }
  }

  Future<void> deleteTask(String projectId, String taskId, ProjectsProvider projectsProvider) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .delete();
          
      _tasks.removeWhere((t) => t.id == taskId);
      _updateProjectProgress(projectId, projectsProvider);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting task: $e");
      rethrow;
    }
  }

  // Automatically update the project's progress based on completed tasks
  void _updateProjectProgress(String projectId, ProjectsProvider projectsProvider) {
    if (_tasks.isEmpty) {
        projectsProvider.updateProjectStatus(projectId, 'Pending', 0.0);
        return;
    }
    
    int completedTasks = _tasks.where((t) => t.isCompleted).length;
    double progress = completedTasks / _tasks.length;
    
    String status = 'In Progress';
    if (progress == 1.0) {
      status = 'Completed';
    } else if (progress == 0.0) {
      status = 'Pending';
    }
    
    projectsProvider.updateProjectStatus(projectId, status, progress);
  }
}
