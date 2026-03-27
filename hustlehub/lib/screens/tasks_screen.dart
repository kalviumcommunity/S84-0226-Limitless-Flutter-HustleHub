import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hustlehub/providers/tasks_provider.dart';
import 'package:hustlehub/providers/projects_provider.dart';
import 'package:hustlehub/models/project_model.dart';

class TasksScreen extends StatefulWidget {
  final ProjectModel project;

  const TasksScreen({super.key, required this.project});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TasksProvider>(context, listen: false).fetchTasks(widget.project.id);
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Task Title',
              hintText: 'What needs to be done?',
              prefixIcon: const Icon(Icons.task_alt),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
                  Provider.of<TasksProvider>(context, listen: false).addTask(
                    widget.project.id,
                    titleController.text,
                    projectsProvider,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Task created successfully'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTask(BuildContext context, String taskId, String taskTitle, TasksProvider tasksProvider, ProjectsProvider projectsProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Delete "$taskTitle"?\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              tasksProvider.deleteTask(widget.project.id, taskId, projectsProvider);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️  Task deleted'),
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
        title: Text(
          '✓ ${widget.project.title}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: Consumer2<TasksProvider, ProjectsProvider>(
        builder: (context, tasksProvider, projectsProvider, child) {
          if (tasksProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tasksProvider.tasks.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate task stats
          int completedCount = tasksProvider.tasks.where((t) => t.isCompleted).length;
          int totalCount = tasksProvider.tasks.length;

          return Column(
            children: [
              // Stats Bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.withValues(alpha: 0.1), Colors.blue.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$totalCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$completedCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Completed',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${totalCount - completedCount}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Remaining',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tasks List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await tasksProvider.fetchTasks(widget.project.id);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tasksProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasksProvider.tasks[index];
                      return _buildTaskCard(
                        task: task,
                        onToggle: () => tasksProvider.toggleTaskStatus(
                          widget.project.id,
                          task.id,
                          !task.isCompleted,
                          projectsProvider,
                        ),
                        onDelete: () => _confirmDeleteTask(
                          context,
                          task.id,
                          task.title,
                          tasksProvider,
                          projectsProvider,
                        ),
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

  Widget _buildTaskCard({
    required dynamic task,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isCompleted
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.1),
                    border: Border.all(
                      color: task.isCompleted ? Colors.green : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, color: Colors.green, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Task Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration:
                            task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? Colors.grey[500] : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.isCompleted) ...[
                      const SizedBox(height: 4),
                      Text(
                        '✓ Completed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                iconSize: 20,
                onPressed: onDelete,
                splashRadius: 20,
              ),
            ],
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
              Icons.task_alt,
              size: 80,
              color: Colors.blue.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Tasks Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first task',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
