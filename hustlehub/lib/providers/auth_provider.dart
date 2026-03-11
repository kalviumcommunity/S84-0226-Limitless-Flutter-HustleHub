import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  fb.FirebaseAuth get _firebaseAuth => fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _useFirebase = false;
  late final VoidCallback _authListenerCleanup;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get useFirebase => _useFirebase;

  AuthProvider() {
    _useFirebase = Firebase.apps.isNotEmpty;

    if (_useFirebase) {
      final sub = _firebaseAuth.authStateChanges().listen((fbUser) {
        if (fbUser == null) {
          _currentUser = null;
          _isAuthenticated = false;
        } else {
          _currentUser = _mapFirebaseUser(fbUser);
          _isAuthenticated = true;
        }
        notifyListeners();
      });
      _authListenerCleanup = () => sub.cancel();
    } else {
      _authListenerCleanup = () {};
    }
  }

  @override
  void dispose() {
    _authListenerCleanup();
    super.dispose();
  }

  User _mapFirebaseUser(fb.User fbUser) {
    return User(
      id: fbUser.uid,
      name: fbUser.displayName?.trim().isNotEmpty == true
          ? fbUser.displayName!
          : 'Hustler',
      email: fbUser.email ?? '',
      profileImageUrl: fbUser.photoURL,
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useFirebase) {
        final cred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await cred.user?.updateDisplayName(name.trim());
        if (cred.user != null) {
          await _firestore.collection('users').doc(cred.user!.uid).set({
            'id': cred.user!.uid,
            'name': name.trim(),
            'email': email.trim(),
            'createdAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }
        final refreshedUser = _firebaseAuth.currentUser;
        if (refreshedUser != null) {
          _currentUser = _mapFirebaseUser(refreshedUser);
          _isAuthenticated = true;
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _currentUser = User(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useFirebase) {
        final cred = await _firebaseAuth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = cred.user;
        if (fbUser != null) {
          _currentUser = _mapFirebaseUser(fbUser);
          _isAuthenticated = true;
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _currentUser = User(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          name: 'John Doe',
          email: email,
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firebaseAuth.signOut();
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      _currentUser = null;
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
