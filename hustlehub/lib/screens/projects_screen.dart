import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hustlehub/providers/projects_provider.dart';
import 'package:hustlehub/providers/clients_provider.dart';
import 'package:hustlehub/screens/tasks_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectsProvider>(context, listen: false).fetchProjects();
      Provider.of<ClientsProvider>(context, listen: false).fetchClients();
    });
  }

  void _showAddProjectDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDeadline;
    String? selectedClientId;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogTextField(
                      controller: titleController,
                      label: 'Project Title',
                      icon: Icons.folder,
                    ),
                    const SizedBox(height: 20),
                    Consumer<ClientsProvider>(
                      builder: (context, clientsProvider, child) {
                        if (clientsProvider.clients.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: const Text("⚠️ Please add a client first."),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedClientId,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.05),
                          ),
                          hint: const Text("Select Client"),
                          onChanged: (val) {
                            setState(() {
                              selectedClientId = val;
                            });
                          },
                          items: clientsProvider.clients.map((client) {
                            return DropdownMenuItem(
                              value: client.id,
                              child: Text(client.name),
                            );
                          }).toList(),
                        );
                      }
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Project details...',
                        prefixIcon: const Icon(Icons.description),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDeadline == null 
                                  ? '📅 Tap to select deadline' 
                                  : 'Deadline: ${DateFormat('MMM dd, yyyy').format(selectedDeadline!)}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDeadline = pickedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Pick'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && selectedClientId != null && selectedDeadline != null) {
                      Provider.of<ProjectsProvider>(context, listen: false).addProject(
                        selectedClientId!,
                        titleController.text,
                        descriptionController.text,
                        selectedDeadline!,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Project created successfully'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Please fill all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Create Project'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  void _showUpdateStatusDialog(String projectId, String currentStatus, double currentProgress) {
    double newProgress = currentProgress;
    String newStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Project Status', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: newStatus,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.05),
                    ),
                    items: ['Pending', 'In Progress', 'Testing', 'Completed'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        newStatus = val!;
                        if (val == 'Completed') {
                          newProgress = 1.0;
                        } else if (val == 'Pending') {
                          newProgress = 0.0;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(newProgress * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: newProgress,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: Colors.blue,
                    onChanged: newStatus == 'Completed'
                        ? null
                        : (val) {
                          setState(() {
                            newProgress = val;
                          });
                        },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<ProjectsProvider>(context, listen: false)
                        .updateProjectStatus(projectId, newStatus, newProgress);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Project status updated'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteProject(BuildContext context, String projectId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('Delete "$title"?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProjectsProvider>(context, listen: false).deleteProject(projectId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️  Project deleted'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Projects', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
      body: Consumer2<ProjectsProvider, ClientsProvider>(
        builder: (context, projectsProvider, clientsProvider, child) {
          final filteredProjects = projectsProvider.projects.where((p) {
            return p.title.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search projects...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Projects List
              Expanded(
                child: projectsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredProjects.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async {
                              await Future.wait([
                                projectsProvider.fetchProjects(),
                                clientsProvider.fetchClients(),
                              ]);
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredProjects.length,
                              itemBuilder: (context, index) {
                                final project = filteredProjects[index];

                                // Find client name
                                String clientName = "Unknown Client";
                                try {
                                  if (clientsProvider.clients.isNotEmpty) {
                                    clientName = clientsProvider.clients
                                        .firstWhere((c) => c.id == project.clientId)
                                        .name;
                                  }
                                } catch (e) {
                                  // Client not found
                                }

                                final daysUntilDeadline =
                                    project.deadline.difference(DateTime.now()).inDays;
                                final isOverdue = daysUntilDeadline < 0 && project.status != 'Completed';
                                final isUrgent = daysUntilDeadline <= 7 && project.status != 'Completed';

                                return _buildProjectCard(
                                  project: project,
                                  clientName: clientName,
                                  isOverdue: isOverdue,
                                  isUrgent: isUrgent,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TasksScreen(project: project),
                                      ),
                                    );
                                  },
                                  onEdit: () => _showUpdateStatusDialog(project.id, project.status, project.progress),
                                  onDelete: () => _confirmDeleteProject(context, project.id, project.title),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProjectCard({
    required dynamic project,
    required String clientName,
    required bool isOverdue,
    required bool isUrgent,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue
                  ? Colors.red.withValues(alpha: 0.3)
                  : isUrgent
                      ? Colors.orange.withValues(alpha: 0.3)
                      : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: project.status == 'Completed'
                            ? Colors.green.withValues(alpha: 0.15)
                            : project.status == 'In Progress'
                                ? Colors.blue.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        project.status == 'Completed'
                            ? Icons.task_alt
                            : project.status == 'In Progress'
                                ? Icons.work
                                : Icons.folder_open,
                        color: project.status == 'Completed'
                            ? Colors.green
                            : project.status == 'In Progress'
                                ? Colors.blue
                                : Colors.grey,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            clientName,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        project.status,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: project.status == 'Completed'
                              ? Colors.green
                              : project.status == 'In Progress'
                                  ? Colors.blue
                                  : Colors.grey[700],
                        ),
                      ),
                      backgroundColor: project.status == 'Completed'
                          ? Colors.green.withValues(alpha: 0.15)
                          : project.status == 'In Progress'
                              ? Colors.blue.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: project.status == 'Completed'
                            ? Colors.green.withValues(alpha: 0.5)
                            : project.status == 'In Progress'
                                ? Colors.blue.withValues(alpha: 0.5)
                                : Colors.grey.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description (if exists)
                if (project.description.isNotEmpty) ...[
                  Text(
                    project.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],

                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: project.progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            project.progress == 1.0 ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(project.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 12),

                // Deadline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deadline',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd, yyyy').format(project.deadline),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isOverdue ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⚠️ Overdue',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )
                    else if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🔶 Due Soon',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          onPressed: onEdit,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: onDelete,
                          color: Colors.red,
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.blue.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Projects Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first project',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
