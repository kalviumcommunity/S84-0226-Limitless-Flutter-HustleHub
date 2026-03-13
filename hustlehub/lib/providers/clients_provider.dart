import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/client_model.dart';

class ClientsProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get _useFirebase => Firebase.apps.isNotEmpty;

  ClientsProvider() {
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
      _clients = [];
      notifyListeners();
      return;
    }

    if (_useFirebase) {
      _isLoading = true;
      notifyListeners();

      _subscription = _firestore
          .collection('clients')
          .where('userId', isEqualTo: _userId)
          .snapshots()
          .listen(
            (snapshot) {
              _clients = snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Client.fromMap(data);
              }).toList();
              _isLoading = false;
              notifyListeners();
            },
            onError: (Object e) {
              _isLoading = false;
              _error = 'Failed to stream clients: $e';
              notifyListeners();
            },
          );
    } else {
      _initializeMockData(userId: _userId!);
      notifyListeners();
    }
  }

  void _initializeMockData({String userId = 'user1'}) {
    _clients = [
      Client(
        id: '1',
        userId: userId,
        name: 'Tech Innovations Inc',
        email: 'contact@techinnovations.com',
        phone: '+1-555-0101',
        company: 'Tech Innovations Inc',
        address: '123 Silicon Valley Road, CA 94025',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastContactDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Client(
        id: '2',
        userId: userId,
        name: 'Design Studio Co',
        email: 'hello@designstudio.com',
        phone: '+1-555-0102',
        company: 'Design Studio Co',
        address: '456 Creative Lane, NY 10001',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastContactDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Client(
        id: '3',
        userId: userId,
        name: 'StartUp Ventures',
        email: 'team@startupventures.io',
        phone: '+1-555-0103',
        company: 'StartUp Ventures',
        address: '789 Innovation Blvd, TX 75001',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastContactDate: DateTime.now(),
      ),
    ];
  }

  Future<void> addClient(Client client) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalized = client.copyWith(userId: _userId ?? client.userId);
      if (_useFirebase) {
        await _firestore
            .collection('clients')
            .doc(normalized.id)
            .set(normalized.toMap());
      } else {
        _clients.add(normalized);
      }
    } catch (e) {
      _error = 'Failed to add client: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateClient(Client client) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore
            .collection('clients')
            .doc(client.id)
            .update(client.toMap());
      } else {
        final index = _clients.indexWhere((c) => c.id == client.id);
        if (index == -1) throw Exception('Client not found');
        _clients[index] = client;
      }
    } catch (e) {
      _error = 'Failed to update client: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClient(String clientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore.collection('clients').doc(clientId).delete();
      } else {
        _clients.removeWhere((c) => c.id == clientId);
      }
    } catch (e) {
      _error = 'Failed to delete client: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Client? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c.id == clientId);
    } catch (_) {
      return null;
    }
  }

  List<Client> searchClients(String query) {
    if (query.isEmpty) return _clients;
    return _clients
        .where(
          (client) =>
              client.name.toLowerCase().contains(query.toLowerCase()) ||
              client.company.toLowerCase().contains(query.toLowerCase()) ||
              client.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<void> fetchClients(String userId) async {
    updateUserId(userId);
  }
}
