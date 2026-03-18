import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/payment_model.dart';

class PaymentsProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get _useFirebase => Firebase.apps.isNotEmpty;

  PaymentsProvider() {
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
      _payments = [];
      notifyListeners();
      return;
    }

    if (_useFirebase) {
      _isLoading = true;
      notifyListeners();

      _subscription = _firestore
          .collection('payments')
          .where('userId', isEqualTo: _userId)
          .snapshots()
          .listen(
            (snapshot) {
              _payments = snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Payment.fromMap(data);
              }).toList();
              _isLoading = false;
              notifyListeners();
            },
            onError: (Object e) {
              _isLoading = false;
              _error = 'Failed to stream payments: $e';
              notifyListeners();
            },
          );
    } else {
      _initializeMockData(userId: _userId!);
      notifyListeners();
    }
  }

  void _initializeMockData({String userId = 'user1'}) {
    _payments = [
      Payment(
        id: '1',
        projectId: 'proj1',
        clientId: 'client1',
        userId: userId,
        amount: 5000,
        status: PaymentStatus.completed,
        method: PaymentMethod.bankTransfer,
        description: 'First milestone payment - Design Phase',
        dueDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        paidDate: DateTime.now().subtract(const Duration(days: 10)),
        invoiceNumber: 'INV-001',
      ),
      Payment(
        id: '2',
        projectId: 'proj1',
        clientId: 'client1',
        userId: userId,
        amount: 3000,
        status: PaymentStatus.pending,
        method: PaymentMethod.creditCard,
        description: 'Second milestone - Development Phase',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        invoiceNumber: 'INV-002',
      ),
    ];
  }

  Future<void> addPayment(Payment payment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalized = payment.copyWith(userId: _userId ?? payment.userId);
      if (_useFirebase) {
        await _firestore
            .collection('payments')
            .doc(normalized.id)
            .set(normalized.toMap());
      } else {
        _payments.add(normalized);
      }
    } catch (e) {
      _error = 'Failed to add payment: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePayment(Payment payment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore
            .collection('payments')
            .doc(payment.id)
            .update(payment.toMap());
      } else {
        final index = _payments.indexWhere((p) => p.id == payment.id);
        if (index == -1) throw Exception('Payment not found');
        _payments[index] = payment;
      }
    } catch (e) {
      _error = 'Failed to update payment: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePayment(String paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore.collection('payments').doc(paymentId).delete();
      } else {
        _payments.removeWhere((p) => p.id == paymentId);
      }
    } catch (e) {
      _error = 'Failed to delete payment: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus newStatus,
  ) async {
    final payment = _payments.firstWhere((p) => p.id == paymentId);
    await updatePayment(
      payment.copyWith(
        status: newStatus,
        paidDate: newStatus == PaymentStatus.completed ? DateTime.now() : null,
      ),
    );
  }

  Future<void> markAsPaid(String paymentId) async {
    await updatePaymentStatus(paymentId, PaymentStatus.completed);
  }

  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((payment) => payment.status == status).toList();
  }

  List<Payment> getPendingPayments() =>
      getPaymentsByStatus(PaymentStatus.pending);
  List<Payment> getCompletedPayments() =>
      getPaymentsByStatus(PaymentStatus.completed);
  List<Payment> getOverduePayments() =>
      _payments.where((payment) => payment.isOverdue).toList();

  double getTotalRevenue() {
    return _payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0, (totalAmount, payment) => totalAmount + payment.amount);
  }

  double getTotalPending() {
    return _payments
        .where((p) => p.status == PaymentStatus.pending)
        .fold(0, (totalAmount, payment) => totalAmount + payment.amount);
  }

  List<Payment> getPaymentsByProject(String projectId) {
    return _payments
        .where((payment) => payment.projectId == projectId)
        .toList();
  }

  List<Payment> getPaymentsByClient(String clientId) {
    return _payments.where((payment) => payment.clientId == clientId).toList();
  }

  Payment? getPaymentById(String paymentId) {
    try {
      return _payments.firstWhere((p) => p.id == paymentId);
    } catch (_) {
      return null;
    }
  }

  List<Payment> searchPayments(String query) {
    if (query.isEmpty) return _payments;
    return _payments
        .where(
          (payment) =>
              (payment.invoiceNumber?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              payment.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<void> fetchPayments(String userId) async {
    updateUserId(userId);
  }
}
