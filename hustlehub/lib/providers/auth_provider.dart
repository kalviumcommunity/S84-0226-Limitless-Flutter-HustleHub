import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustlehub/models/user_model.dart';
import 'package:hustlehub/utils/error_handler.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          _fetchUserData(user.uid);
        } else {
          _currentUser = null;
          _errorMessage = null;
          notifyListeners();
        }
      }, onError: (error) {
        _errorMessage = ErrorHandler.getErrorMessage(error);
        debugPrint('❌ Auth state error: $error');
      });
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      debugPrint('❌ Error listening to auth changes: $e');
    }
  }

  Future<void> _fetchUserData(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        debugPrint('✅ User data fetched: ${_currentUser?.email}');
      } else {
        debugPrint('⚠️ User document not found: $uid');
      }
    } on FirebaseException catch (e) {
      _errorMessage = ErrorHandler.getFirestoreErrorMessage(e);
      debugPrint("❌ Firestore error fetching user: ${_errorMessage}");
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      debugPrint("❌ Error fetching user data: ${_errorMessage}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      _errorMessage = null;
      debugPrint('✅ User logged out successfully');
    } on FirebaseAuthException catch (e) {
      _errorMessage = ErrorHandler.getAuthErrorMessage(e);
      debugPrint('❌ Error during logout: ${_errorMessage}');
      rethrow;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      debugPrint('❌ Error during logout: ${_errorMessage}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserName(String newName) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      return;
    }
    
    if (newName.trim().isEmpty) {
      _errorMessage = 'Name cannot be empty';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
            'name': newName.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        name: newName.trim(),
        email: _currentUser!.email,
        createdAt: _currentUser!.createdAt,
      );
      _errorMessage = null;
      debugPrint('✅ User name updated to: $newName');
    } on FirebaseException catch (e) {
      _errorMessage = ErrorHandler.getFirestoreErrorMessage(e);
      debugPrint("❌ Firestore error updating name: ${_errorMessage}");
      rethrow;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      debugPrint("❌ Error updating user name: ${_errorMessage}");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
