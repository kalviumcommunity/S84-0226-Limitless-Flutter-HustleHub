import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hustlehub/models/payment_model.dart';

class PaymentsProvider with ChangeNotifier {
  List<PaymentModel> _payments = [];
  bool _isLoading = false;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;

  PaymentsProvider() {
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('userId', isEqualTo: user.uid)
          .get();

      _payments = snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Sort so 'Pending' and closest due dates are generally at top
      _payments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      debugPrint("Error fetching payments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPayment(String clientId, String title, double amount, DateTime dueDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final newPayment = PaymentModel(
        id: '',
        userId: user.uid,
        clientId: clientId,
        title: title,
        amount: amount,
        dueDate: dueDate,
      );

      final docRef = await FirebaseFirestore.instance.collection('payments').add(newPayment.toMap());
      
      final addedPayment = PaymentModel(
        id: docRef.id,
        userId: user.uid,
        clientId: clientId,
        title: title,
        amount: amount,
        dueDate: dueDate,
      );
      
      _payments.insert(0, addedPayment);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding payment: $e");
      rethrow;
    }
  }

  Future<void> markAsPaid(String paymentId) async {
    try {
      final now = DateTime.now();
      await FirebaseFirestore.instance.collection('payments').doc(paymentId).update({
        'status': 'Completed',
        'paidDate': Timestamp.fromDate(now),
      });

      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        final current = _payments[index];
        _payments[index] = PaymentModel(
          id: current.id,
          userId: current.userId,
          clientId: current.clientId,
          title: current.title,
          amount: current.amount,
          status: 'Completed',
          dueDate: current.dueDate,
          paidDate: now,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking payment as paid: $e");
      rethrow;
    }
  }

  Future<void> deletePayment(String paymentId) async {
    try {
      await FirebaseFirestore.instance.collection('payments').doc(paymentId).delete();
      _payments.removeWhere((p) => p.id == paymentId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting payment: $e");
      rethrow;
    }
  }
}
