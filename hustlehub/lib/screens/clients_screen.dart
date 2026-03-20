import 'package:flutter/material.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text('C${index + 1}', style: const TextStyle(color: Colors.deepPurple)),
              ),
              title: Text('Client ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('client${index + 1}@example.com'),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {},
                color: Colors.green,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF6200EA),
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
