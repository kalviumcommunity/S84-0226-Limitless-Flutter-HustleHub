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
              title: const Text('Add New Project'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Project Title'),
                    ),
                    const SizedBox(height: 10),
                    Consumer<ClientsProvider>(
                      builder: (context, clientsProvider, child) {
                        if (clientsProvider.clients.isEmpty) {
                          return const Text("Please add a client first.");
                        }
                        return DropdownButtonFormField<String>(
                          value: selectedClientId,
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text(selectedDeadline == null 
                            ? 'No Deadline Chosen' 
                            : 'Deadline: ${DateFormat('MMM dd, yyyy').format(selectedDeadline!)}'),
                        const Spacer(),
                        TextButton(
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
                          child: const Text('Pick Date'),
                        ),
                      ],
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
                  onPressed: () {
                    if (titleController.text.isNotEmpty && selectedClientId != null && selectedDeadline != null) {
                      Provider.of<ProjectsProvider>(context, listen: false).addProject(
                        selectedClientId!,
                        titleController.text,
                        descriptionController.text,
                        selectedDeadline!,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
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
                title: const Text('Update Project Status'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                        value: newStatus,
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
                        }
                    ),
                    const SizedBox(height: 20),
                    Text('Progress: ${(newProgress * 100).toInt()}%'),
                    Slider(
                      value: newProgress,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: newStatus == 'Completed' ? null : (val) {
                        setState(() {
                          newProgress = val;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<ProjectsProvider>(context, listen: false)
                          .updateProjectStatus(projectId, newStatus, newProgress);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            }
          );
        }
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects Overview'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer2<ProjectsProvider, ClientsProvider>(
        builder: (context, projectsProvider, clientsProvider, child) {
          if (projectsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (projectsProvider.projects.isEmpty) {
            return const Center(child: Text("No projects found. Add one above."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: projectsProvider.projects.length,
            itemBuilder: (context, index) {
              final project = projectsProvider.projects[index];
              
              // Find client name
              String clientName = "Unknown Client";
              try {
                if (clientsProvider.clients.isNotEmpty) {
                    clientName = clientsProvider.clients.firstWhere((c) => c.id == project.clientId).name;
                }
              } catch (e) {
                // Client not found or not loaded
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TasksScreen(project: project),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              project.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(project.status),
                            backgroundColor: project.status == 'Completed' 
                                ? Colors.green.withValues(alpha: 0.2) 
                                : Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Client: $clientName', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Text('Deadline: ${DateFormat('MMM dd, yyyy').format(project.deadline)}'),
                      if (project.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(project.description),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: project.progress,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('${(project.progress * 100).toInt()}%'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            TextButton.icon(
                                onPressed: () => _showUpdateStatusDialog(project.id, project.status, project.progress), 
                                icon: const Icon(Icons.edit), 
                                label: const Text('Update Status')
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                    showDialog(
                                        context: context, 
                                        builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Project?'),
                                            content: const Text('This action cannot be undone.'),
                                            actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                TextButton(
                                                    onPressed: () {
                                                        Provider.of<ProjectsProvider>(context, listen: false).deleteProject(project.id);
                                                        Navigator.pop(ctx);
                                                    }, 
                                                    child: const Text('Delete', style: TextStyle(color: Colors.red))
                                                ),
                                            ],
                                        )
                                    );
                                },
                            ),
                        ],
                      )
                    ],
                  ),
                ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
