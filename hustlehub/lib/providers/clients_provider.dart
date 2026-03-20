import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hustlehub/models/client_model.dart';

class ClientsProvider with ChangeNotifier {
  List<ClientModel> _clients = [];
  bool _isLoading = false;

  List<ClientModel> get clients => _clients;
  bool get isLoading => _isLoading;

  ClientsProvider() {
    fetchClients();
  }

  Future<void> fetchClients() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('userId', isEqualTo: user.uid)
          .get();

      _clients = snapshot.docs
          .map((doc) => ClientModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Sort locally to avoid needing a complex Firestore composite index immediately
      _clients.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      
    } catch (e) {
      debugPrint("Error fetching clients: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addClient(String name, String email, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final newClient = ClientModel(
        id: '', // Firestore will generate the ID
        userId: user.uid,
        name: name,
        email: email,
        phone: phone,
      );

      final docRef = await FirebaseFirestore.instance.collection('clients').add(newClient.toMap());
      
      // Optimistically update local state so UI reflects instantly without a full loading screen
      final addedClient = ClientModel(
        id: docRef.id,
        userId: user.uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      
      _clients.insert(0, addedClient);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding client: $e");
      rethrow;
    }
  }

  Future<void> updateClient(String clientId, String name, String email, String phone) async {
    try {
      await FirebaseFirestore.instance.collection('clients').doc(clientId).update({
        'name': name,
        'email': email,
        'phone': phone,
      });

      // Update locally
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        final existingClient = _clients[index];
        _clients[index] = ClientModel(
          id: existingClient.id,
          userId: existingClient.userId,
          name: name,
          email: email,
          phone: phone,
          createdAt: existingClient.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating client: $e");
      rethrow;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await FirebaseFirestore.instance.collection('clients').doc(clientId).delete();
      
      // Update locally
      _clients.removeWhere((c) => c.id == clientId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting client: $e");
      rethrow;
    }
  }
}

