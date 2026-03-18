import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/auth_provider.dart';
import '../providers/clients_provider.dart';
import '../providers/payments_provider.dart';
import '../providers/projects_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onNavSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.of(context).pushNamed('/projects');
        break;
      case 2:
        Navigator.of(context).pushNamed('/clients');
        break;
      case 3:
        Navigator.of(context).pushNamed('/profile');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        title: const Text('HustleHub Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryColor,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile) {
              return SingleChildScrollView(
                child: _buildMobileContent(context, user),
              );
            } else {
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onNavSelected,
                    labelType: NavigationRailLabelType.selected,
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.work_outline),
                        selectedIcon: Icon(Icons.work),
                        label: Text('Projects'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(Icons.people),
                        label: Text('Clients'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profile'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildDesktopContent(context, user),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onNavSelected,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work_outline),
                  activeIcon: Icon(Icons.work),
                  label: 'Projects',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Clients',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMobileContent(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(user),
          SizedBox(height: AppSpacing.lg),
          _buildQuickStatsSection(),
          SizedBox(height: AppSpacing.lg),
          _buildRecentProjectsSection(),
          SizedBox(height: AppSpacing.lg),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(user),
          SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildQuickStatsSection(),
                    SizedBox(height: AppSpacing.lg),
                    _buildRecentProjectsSection(),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(flex: 1, child: _buildActionButtons(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, ${user?.name.split(' ')[0]}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          const Text(
            'Here\'s what\'s happening with your projects today',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    final projectsCount = context.watch<ProjectsProvider>().projects.length;
    final tasksCount = context.watch<TasksProvider>().tasks.length;
    final clientsCount = context.watch<ClientsProvider>().clients.length;
    final revenue = context.watch<PaymentsProvider>().getTotalRevenue();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 400;
            return GridView.count(
              crossAxisCount: isMobile ? 2 : 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              children: [
                _buildStatCard(
                  'Projects',
                  '$projectsCount',
                  Icons.work_outline,
                ),
                _buildStatCard('Tasks', '$tasksCount', Icons.checklist),
                _buildStatCard(
                  'Clients',
                  '$clientsCount',
                  Icons.people_outline,
                ),
                if (isMobile)
                  _buildStatCard(
                    'Revenue',
                    '\$${revenue.toStringAsFixed(0)}',
                    Icons.paid_outlined,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 28),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjectsSection() {
    final projects = context.watch<ProjectsProvider>().projects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Projects',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length > 3 ? 3 : projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return _buildProjectTile(
              project.title,
              _statusLabel(project.status),
              project.progressPercentage.round(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProjectTile(String title, String status, int progress) {
    final statusColor = status == 'Completed'
        ? AppColors.successColor
        : status == 'In Review'
        ? AppColors.accentColor
        : AppColors.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
                  status,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '$progress%',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/projects');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Text('Projects'),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/clients');
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_outlined),
              SizedBox(width: AppSpacing.sm),
              Text('Clients'),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/tasks');
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_outlined),
              SizedBox(width: AppSpacing.sm),
              Text('Tasks'),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/payments');
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_outlined),
              SizedBox(width: AppSpacing.sm),
              Text('Payments'),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/profile');
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outlined),
              SizedBox(width: AppSpacing.sm),
              Text('Profile'),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () async {
            if (mounted) {
              final ctx = context;
              await ctx.read<AuthProvider>().signOut();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(
                  ctx,
                ).pushNamedAndRemoveUntil('/signin', (route) => false);
              });
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            side: const BorderSide(color: AppColors.errorColor),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: AppColors.errorColor),
              SizedBox(width: AppSpacing.sm),
              Text('Sign Out', style: TextStyle(color: AppColors.errorColor)),
            ],
          ),
        ),
      ],
    );
  }
}
