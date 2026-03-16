import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/project_model.dart';

class ProjectsProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get _useFirebase => Firebase.apps.isNotEmpty;

  ProjectsProvider() {
    _initializeMockData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void updateUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;

    _subscription?.cancel();
    _error = null;

    if (_userId == null || _userId!.isEmpty) {
      _projects = [];
      notifyListeners();
      return;
    }

    if (_useFirebase) {
      _isLoading = true;
      notifyListeners();

      _subscription = _firestore
          .collection('projects')
          .where('userId', isEqualTo: _userId)
          .snapshots()
          .listen(
            (snapshot) {
              _projects = snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Project.fromMap(data);
              }).toList();
              _isLoading = false;
              notifyListeners();
            },
            onError: (Object e) {
              _isLoading = false;
              _error = 'Failed to stream projects: $e';
              notifyListeners();
            },
          );
    } else {
      _initializeMockData(userId: _userId!);
      notifyListeners();
    }
  }

  void _initializeMockData({String userId = 'user1'}) {
    _projects = [
      Project(
        id: 'proj1',
        clientId: '1',
        userId: userId,
        title: 'Mobile App Redesign',
        description: 'Redesign the mobile application UI/UX',
        status: ProjectStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 35)),
        budget: 12000,
        amountPaid: 5000,
        createdAt: DateTime.now().subtract(const Duration(days: 32)),
        teamMembers: const ['user1', 'user2', 'user3', 'user4'],
      ),
      Project(
        id: 'proj2',
        clientId: '2',
        userId: userId,
        title: 'Website Redesign',
        description: 'Complete website overhaul and modernization',
        status: ProjectStatus.onHold,
        startDate: DateTime.now().subtract(const Duration(days: 55)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        budget: 9000,
        amountPaid: 7500,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        teamMembers: const ['user1', 'user2', 'user5'],
      ),
    ];
  }

  Future<void> addProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalized = project.copyWith(userId: _userId ?? project.userId);
      if (_useFirebase) {
        await _firestore
            .collection('projects')
            .doc(normalized.id)
            .set(normalized.toMap());
      } else {
        _projects.add(normalized);
      }
    } catch (e) {
      _error = 'Failed to add project: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore
            .collection('projects')
            .doc(project.id)
            .update(project.toMap());
      } else {
        final index = _projects.indexWhere((p) => p.id == project.id);
        if (index == -1) throw Exception('Project not found');
        _projects[index] = project;
      }
    } catch (e) {
      _error = 'Failed to update project: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore.collection('projects').doc(projectId).delete();
      } else {
        _projects.removeWhere((p) => p.id == projectId);
      }
    } catch (e) {
      _error = 'Failed to delete project: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Project> searchProjects(String query) {
    if (query.trim().isEmpty) return _projects;
    final searchText = query.toLowerCase().trim();
    return _projects.where((project) {
      return project.title.toLowerCase().contains(searchText) ||
          project.description.toLowerCase().contains(searchText);
    }).toList();
  }

  List<Project> filterByStatus(ProjectStatus? status) {
    if (status == null) return _projects;
    return _projects.where((project) => project.status == status).toList();
  }

  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (_) {
      return null;
    }
  }
}
