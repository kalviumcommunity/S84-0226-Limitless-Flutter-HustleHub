import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hustlehub/providers/clients_provider.dart';
import 'package:hustlehub/models/client_model.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch clients freshly when jumping to this tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientsProvider>(context, listen: false).fetchClients();
    });
  }

  void _showAddClientDialog(BuildContext context, {ClientModel? existingClient}) {
    final isEditing = existingClient != null;
    final nameController = TextEditingController(text: existingClient?.name ?? '');
    final emailController = TextEditingController(text: existingClient?.email ?? '');
    final phoneController = TextEditingController(text: existingClient?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Client' : 'Add New Client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Client Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                
                try {
                  if (isEditing) {
                    await Provider.of<ClientsProvider>(context, listen: false).updateClient(
                      existingClient.id,
                      nameController.text.trim(),
                      emailController.text.trim(),
                      phoneController.text.trim(),
                    );
                  } else {
                    await Provider.of<ClientsProvider>(context, listen: false).addClient(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      phoneController.text.trim(),
                    );
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Client updated successfully' : 'Client added successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String clientId, String clientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete $clientName?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<ClientsProvider>(context, listen: false).deleteClient(clientId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Client deleted successfully'), backgroundColor: Colors.redAccent),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientsProvider>(context);
    
    // Filter clients based on search query
    final filteredClients = clientsProvider.clients.where((client) {
      return client.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             client.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clients by name or email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: clientsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredClients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Text(
                            client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          client.email.isNotEmpty ? client.email : (client.phone.isNotEmpty ? client.phone : 'No contact info'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddClientDialog(context, existingClient: client),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, client.id, client.name),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ), // End of Expanded
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientDialog(context),
        tooltip: 'Add Client',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No clients yet',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the + button to add your first client.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
