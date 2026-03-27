import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Error handler for Firebase and app errors
class ErrorHandler {
  /// Parse Firebase Auth errors
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use uppercase, numbers, and special characters.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Parse Firestore errors
  static String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested document does not exist.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request took too long. Please try again.';
      case 'already-exists':
        return 'This document already exists.';
      case 'invalid-argument':
        return 'Invalid data provided. Please check your input.';
      default:
        return 'Database error: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Generic error message
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return getAuthErrorMessage(error);
    } else if (error is FirebaseException) {
      return getFirestoreErrorMessage(error);
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception:', '').trim();
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Format error for user display
  static String formatErrorForUser(dynamic error) {
    final message = getErrorMessage(error);
    // Remove technical details
    return message.split('(').first.trim();
  }
}
