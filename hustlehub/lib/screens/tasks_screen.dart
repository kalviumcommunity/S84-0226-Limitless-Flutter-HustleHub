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
          title: const Text('New Task'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
                  Provider.of<TasksProvider>(context, listen: false).addTask(
                    widget.project.id,
                    titleController.text,
                    projectsProvider,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.title} - Tasks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer2<TasksProvider, ProjectsProvider>(
        builder: (context, tasksProvider, projectsProvider, child) {
          if (tasksProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tasksProvider.tasks.isEmpty) {
            return const Center(child: Text("No tasks yet. Create one!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasksProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = tasksProvider.tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  value: task.isCompleted,
                  onChanged: (bool? val) {
                    if (val != null) {
                      tasksProvider.toggleTaskStatus(
                          widget.project.id, task.id, val, projectsProvider);
                    }
                  },
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                       tasksProvider.deleteTask(widget.project.id, task.id, projectsProvider);
                    },
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
