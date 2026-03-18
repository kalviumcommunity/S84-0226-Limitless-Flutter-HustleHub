import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/projects_provider.dart';
import '../utils/constants.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _selectedFilter = 0;
  final List<String> filters = [
    'All',
    'Active',
    'Completed',
    'On Hold',
    'Archived',
  ];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        title: const Text('Projects'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () {
                _showNewProjectDialog(context);
              },
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
                _buildSearchBar(),
                SizedBox(height: AppSpacing.lg),
                _buildFilterChips(),
                SizedBox(height: AppSpacing.lg),
                _buildProjectsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search projects...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
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
            padding: const EdgeInsets.only(right: AppSpacing.sm),
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

  Widget _buildProjectsList() {
    return Consumer<ProjectsProvider>(
      builder: (context, projectsProvider, child) {
        if (projectsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final projects = _getFilteredProjects(projectsProvider);
        if (projects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No projects found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            if (isMobile) {
              return Column(
                children: projects.map((project) {
                  return _buildProjectCard(project, true);
                }).toList(),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(projects[index], false);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProjectCard(Project project, bool isListView) {
    final statusColor = _statusColor(project.status);
    final progress = project.progressPercentage.round();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: isListView ? const EdgeInsets.only(bottom: AppSpacing.md) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  _statusLabel(project.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            project.description,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: project.progressPercentage / 100,
              minHeight: 6,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '${project.teamMembers.length} members',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due: ${project.endDate.toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showEditProjectDialog(context, project),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => _deleteProject(context, project.id),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewProjectDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final budgetController = TextEditingController();
    DateTime selectedEndDate = DateTime.now().add(const Duration(days: 30));
    ProjectStatus status = ProjectStatus.active;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Create New Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(labelText: 'Budget'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<ProjectStatus>(
                  initialValue: status,
                  items: ProjectStatus.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_statusLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() => status = value);
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Date'),
                  subtitle: Text(selectedEndDate.toString().split(' ')[0]),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 1000)),
                    );
                    if (picked != null) {
                      setLocalState(() => selectedEndDate = picked);
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
                    descController.text.trim().isEmpty ||
                    budgetController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final budget = double.tryParse(budgetController.text.trim());
                if (budget == null || budget <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid budget'),
                    ),
                  );
                  return;
                }

                await context.read<ProjectsProvider>().addProject(
                  Project(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    clientId: '1',
                    userId: 'user1',
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    status: status,
                    startDate: DateTime.now(),
                    endDate: selectedEndDate,
                    budget: budget,
                    amountPaid: 0,
                    createdAt: DateTime.now(),
                    teamMembers: const ['user1'],
                  ),
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project created successfully')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    final titleController = TextEditingController(text: project.title);
    final descController = TextEditingController(text: project.description);
    final budgetController = TextEditingController(
      text: project.budget.toStringAsFixed(0),
    );
    DateTime selectedEndDate = project.endDate;
    ProjectStatus status = project.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(labelText: 'Budget'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<ProjectStatus>(
                  initialValue: status,
                  items: ProjectStatus.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_statusLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() => status = value);
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Date'),
                  subtitle: Text(selectedEndDate.toString().split(' ')[0]),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 1000)),
                    );
                    if (picked != null) {
                      setLocalState(() => selectedEndDate = picked);
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
                final budget = double.tryParse(budgetController.text.trim());
                if (titleController.text.trim().isEmpty ||
                    descController.text.trim().isEmpty ||
                    budget == null ||
                    budget <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid details')),
                  );
                  return;
                }

                await context.read<ProjectsProvider>().updateProject(
                  project.copyWith(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    budget: budget,
                    status: status,
                    endDate: selectedEndDate,
                  ),
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project updated successfully')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProject(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ProjectsProvider>().deleteProject(projectId);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<Project> _getFilteredProjects(ProjectsProvider provider) {
    final query = _searchController.text.trim();
    final List<Project> baseList = query.isEmpty
        ? provider.projects
        : provider.searchProjects(query);

    final ProjectStatus? selectedStatus = switch (_selectedFilter) {
      1 => ProjectStatus.active,
      2 => ProjectStatus.completed,
      3 => ProjectStatus.onHold,
      4 => ProjectStatus.archived,
      _ => null,
    };

    if (selectedStatus == null) return baseList;
    return baseList
        .where((project) => project.status == selectedStatus)
        .toList();
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.primaryColor;
      case ProjectStatus.completed:
        return AppColors.successColor;
      case ProjectStatus.onHold:
        return AppColors.accentColor;
      case ProjectStatus.archived:
        return AppColors.textSecondaryColor;
    }
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }
}
