import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hustlehub/providers/auth_provider.dart';
import 'package:hustlehub/providers/clients_provider.dart';
import 'package:hustlehub/providers/projects_provider.dart';
import 'package:hustlehub/providers/payments_provider.dart';
import 'package:hustlehub/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    // Fetch data in case it wasn't fetched yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientsProvider>(context, listen: false).fetchClients();
      Provider.of<ProjectsProvider>(context, listen: false).fetchProjects();
      Provider.of<PaymentsProvider>(context, listen: false).fetchPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider to get real-time user data
    final authProvider = Provider.of<AuthProvider>(context);
    final clientsProvider = Provider.of<ClientsProvider>(context);
    final projectsProvider = Provider.of<ProjectsProvider>(context);
    final paymentsProvider = Provider.of<PaymentsProvider>(context);
    
    final user = authProvider.currentUser;

    // Determine greeting name
    String greetingName = 'Freelancer';
    if (authProvider.isLoading) {
      greetingName = 'Loading...';
    } else if (user != null && user.name.isNotEmpty) {
      greetingName = user.name.split(' ').first; // Use first name
    }

    // Calculations
    int totalClients = clientsProvider.clients.length;
    
    int activeProjects = projectsProvider.projects.where((p) => p.status != 'Completed').length;
    
    double unpaidInvoices = 0.0;
    for (var payment in paymentsProvider.payments) {
      if (payment.status != 'Completed') {
        unpaidInvoices += payment.amount;
      }
    }

    double totalEarnings = 0.0;
    for (var payment in paymentsProvider.payments) {
      if (payment.status == 'Completed') {
        totalEarnings += payment.amount;
      }
    }

    final currencyFormatter = NumberFormat.simpleCurrency(name: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await clientsProvider.fetchClients();
          await projectsProvider.fetchProjects();
          await paymentsProvider.fetchPayments();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $greetingName! \u{1F44B}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Here is an overview of your hustle.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Active Projects', '$activeProjects', Icons.folder, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Total Clients', '$totalClients', Icons.people, Colors.purple)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildSummaryCard('Unpaid Invoices', currencyFormatter.format(unpaidInvoices), Icons.money_off, Colors.red)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildSummaryCard('Total Earnings', currencyFormatter.format(totalEarnings), Icons.account_balance_wallet, Colors.green)),
                ],
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Recent Projects',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (projectsProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (projectsProvider.projects.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No projects found. Go to Projects tab to add one!"),
                ))
              else
                ...projectsProvider.projects.take(3).map((project) {
                    final isUrgent = project.deadline.difference(DateTime.now()).inDays <= 2 && project.status != 'Completed';
                    return _buildTaskTile(
                        project.title, 
                        'Due: ${DateFormat('MMM dd, yyyy').format(project.deadline)} - ${project.status}', 
                        isUrgent,
                        context
                    );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTaskTile(String title, String subtitle, bool isUrgent, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUrgent ? Colors.red.shade100 : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            isUrgent ? Icons.warning_amber_rounded : Icons.work_outline,
            color: isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
