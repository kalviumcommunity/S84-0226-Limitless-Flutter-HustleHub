import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hustlehub/models/project_model.dart';

class ProjectsProvider with ChangeNotifier {
  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  ProjectsProvider() {
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: user.uid)
          .get();

      _projects = snapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Sort locally by closest deadline
      _projects.sort((a, b) => a.deadline.compareTo(b.deadline));
      
    } catch (e) {
      debugPrint("Error fetching projects: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject(String clientId, String title, String description, DateTime deadline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final newProject = ProjectModel(
        id: '',
        userId: user.uid,
        clientId: clientId,
        title: title,
        description: description,
        deadline: deadline,
        status: 'In Progress',
        progress: 0.1,
      );

      final docRef = await FirebaseFirestore.instance.collection('projects').add(newProject.toMap());
      
      final addedProject = ProjectModel(
        id: docRef.id,
        userId: user.uid,
        clientId: clientId,
        title: title,
        description: description,
        deadline: deadline,
        status: 'In Progress',
        progress: 0.1,
        createdAt: DateTime.now(),
      );
      
      _projects.insert(0, addedProject);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding project: $e");
      rethrow;
    }
  }

  Future<void> updateProjectStatus(String projectId, String status, double progress) async {
    try {
      await FirebaseFirestore.instance.collection('projects').doc(projectId).update({
        'status': status,
        'progress': progress,
      });

      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final current = _projects[index];
        _projects[index] = ProjectModel(
          id: current.id,
          userId: current.userId,
          clientId: current.clientId,
          title: current.title,
          description: current.description,
          deadline: current.deadline,
          status: status,
          progress: progress,
          createdAt: current.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating project: $e");
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await FirebaseFirestore.instance.collection('projects').doc(projectId).delete();
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting project: $e");
      rethrow;
    }
  }
}
