import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/tasks_provider.dart';
import '../utils/constants.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedFilter = 0;
  final List<String> filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'On Hold',
  ];
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        title: const Text('Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterChips(),
                SizedBox(height: AppSpacing.lg),
                _buildTasksList(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          filters.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilterChip(
              label: Text(filters[index]),
              selected: _selectedFilter == index,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(bool isMobile) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        if (tasksProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Task> filteredTasks = _getFilteredTasks(tasksProvider);

        if (filteredTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: AppColors.textSecondaryColor,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return _buildTaskCard(context, task, isMobile);
          },
        );
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, bool isMobile) {
    final statusColor = _getStatusColor(task.status);
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () => _showEditTaskDialog(context, task),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () => _deleteTask(context, task.id),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                // Status Badge
                Chip(
                  label: Text(task.status.toString().split('.').last),
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: statusColor),
                  avatar: Icon(
                    _getStatusIcon(task.status),
                    color: statusColor,
                    size: 16,
                  ),
                ),
                // Priority Badge
                Chip(
                  label: Text('Priority ${task.priority}'),
                  backgroundColor: priorityColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: priorityColor),
                ),
                // Deadline
                if (task.isOverdue)
                  Chip(
                    label: const Text('Overdue'),
                    backgroundColor: AppColors.errorColor.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: TextStyle(color: AppColors.errorColor),
                  )
                else if (task.isDeadlineToday)
                  Chip(
                    label: const Text('Due Today'),
                    backgroundColor: AppColors.accentColor.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: TextStyle(color: AppColors.accentColor),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondaryColor,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          'Due: ${task.deadline.toString().split(' ')[0]}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.status != TaskStatus.completed)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TasksProvider>().updateTaskStatus(
                        task.id,
                        TaskStatus.completed,
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Complete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 7));
    int selectedPriority = 3;
    TaskStatus selectedStatus = TaskStatus.pending;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: AppSpacing.md),
                ListTile(
                  title: const Text('Deadline'),
                  subtitle: Text(selectedDeadline.toString().split(' ')[0]),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDeadline = picked);
                    }
                  },
                ),
                DropdownButtonFormField<int>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [1, 2, 3, 4, 5]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('Priority $value'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPriority = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TaskStatus.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
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
                if (titleController.text.trim().isEmpty ||
                    descController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Title and description are required'),
                    ),
                  );
                  return;
                }

                await context.read<TasksProvider>().addTask(
                  Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    projectId: 'proj1',
                    userId: 'user1',
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    status: selectedStatus,
                    deadline: selectedDeadline,
                    createdAt: DateTime.now(),
                    priority: selectedPriority,
                    assignedTo: const ['user1'],
                  ),
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task added successfully')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    int selectedPriority = task.priority;
    TaskStatus selectedStatus = task.status;
    DateTime selectedDeadline = task.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline'),
                  subtitle: Text(selectedDeadline.toString().split(' ')[0]),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setLocalState(() => selectedDeadline = picked);
                    }
                  },
                ),
                DropdownButtonFormField<int>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [1, 2, 3, 4, 5]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('Priority $value'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setLocalState(() => selectedPriority = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TaskStatus.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setLocalState(() => selectedStatus = value);
                    }
                  },
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
                if (titleController.text.trim().isEmpty ||
                    descController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Title and description are required'),
                    ),
                  );
                  return;
                }

                await context.read<TasksProvider>().updateTask(
                  task.copyWith(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    priority: selectedPriority,
                    status: selectedStatus,
                    deadline: selectedDeadline,
                    completedAt: selectedStatus == TaskStatus.completed
                        ? DateTime.now()
                        : null,
                  ),
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task updated successfully')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TasksProvider>().deleteTask(taskId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<Task> _getFilteredTasks(TasksProvider provider) {
    switch (_selectedFilter) {
      case 1:
        return provider.getTasksByStatus(TaskStatus.pending);
      case 2:
        return provider.getTasksByStatus(TaskStatus.inProgress);
      case 3:
        return provider.getTasksByStatus(TaskStatus.completed);
      case 4:
        return provider.getTasksByStatus(TaskStatus.onHold);
      default:
        return provider.tasks;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return AppColors.successColor;
      case TaskStatus.onHold:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.hourglass_bottom;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.onHold:
        return Icons.pause_circle;
    }
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 4) return Colors.red;
    if (priority == 3) return Colors.orange;
    return Colors.green;
  }
}
