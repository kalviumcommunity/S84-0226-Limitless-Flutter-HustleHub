import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hustlehub/providers/auth_provider.dart';
import 'package:hustlehub/providers/clients_provider.dart';
import 'package:hustlehub/providers/projects_provider.dart';
import 'package:hustlehub/providers/payments_provider.dart';
import 'package:hustlehub/screens/profile_screen.dart';
import 'package:hustlehub/screens/tasks_screen.dart';
import 'package:hustlehub/models/project_model.dart';

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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $greetingName! 👋',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Here is an overview of your hustle.',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                  ],
                ),
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
                '📋 Recent Projects',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (projectsProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (projectsProvider.projects.isEmpty)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Projects Yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Go to Projects tab to add one!',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...projectsProvider.projects.take(3).map((project) {
                    final deadlineDays = project.deadline.difference(DateTime.now()).inDays;
                    final isUrgent = deadlineDays <= 2 && project.status != 'Completed';
                    return _buildProjectTile(
                        project,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.05),
              color.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTile(ProjectModel project, String subtitle, bool isUrgent, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isUrgent
                ? [Colors.red.withValues(alpha: 0.02), Colors.red.withValues(alpha: 0.05)]
                : [Colors.blue.withValues(alpha: 0.02), Colors.blue.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TasksScreen(project: project),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isUrgent ? Colors.red.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                      child: Icon(
                        isUrgent ? Icons.warning_amber_rounded : Icons.work_outline,
                        color: isUrgent ? Colors.red : Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Client: ${project.clientId}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: project.progress / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                project.progress == 100 ? Colors.green : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Chip(
                      label: Text(
                        project.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: project.status == 'Completed'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      backgroundColor: project.status == 'Completed'
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
