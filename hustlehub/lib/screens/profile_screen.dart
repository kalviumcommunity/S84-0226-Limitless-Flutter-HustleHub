  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../providers/auth_provider.dart';
  import '../utils/constants.dart';

  class ProfileScreen extends StatefulWidget {
    const ProfileScreen({super.key});

    @override
    State<ProfileScreen> createState() => _ProfileScreenState();
  }

  class _ProfileScreenState extends State<ProfileScreen> {
    bool _isEditing = false;
    late TextEditingController _nameController;
    late TextEditingController _emailController;
    late TextEditingController _bioController;

    @override
    void initState() {
      super.initState();
      final user = context.read<AuthProvider>().currentUser;
      _nameController = TextEditingController(text: user?.name ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _bioController = TextEditingController(text: 'Passionate hustler');
    }

    @override
    void dispose() {
      _nameController.dispose();
      _emailController.dispose();
      _bioController.dispose();
      super.dispose();
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
          title: const Text('Profile'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(_isEditing ? 'Cancel' : 'Edit'),
            ),
            if (_isEditing)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                },
                child: const Text('Save'),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: EdgeInsets.all(
                    isMobile ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      _buildProfileHeader(user),
                      SizedBox(height: AppSpacing.xl),
                      if (_isEditing) _buildEditForm(),
                      if (!_isEditing) _buildProfileInfo(user),
                      SizedBox(height: AppSpacing.xl),
                      _buildSettingsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildProfileHeader(dynamic user) {
      return Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            user?.email ?? 'email@example.com',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryColor),
          ),
        ],
      );
    }

    Widget _buildEditForm() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.lg),
          const Text('Full Name'),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          const Text('Email'),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _emailController,
            enabled: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          const Text('Bio'),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildProfileInfo(dynamic user) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Email', user?.email ?? ''),
          SizedBox(height: AppSpacing.md),
          _buildInfoCard('Bio', 'Passionate hustler'),
          SizedBox(height: AppSpacing.md),
          _buildInfoCard('Joined', 'March 2026'),
        ],
      );
    }

    Widget _buildInfoCard(String label, String value) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderColor),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    Widget _buildSettingsSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          _buildSettingsTile(
            'Notifications',
            'Manage your notifications',
            Icons.notifications_outlined,
            () {},
          ),
          _buildSettingsTile(
            'Privacy',
            'Control your privacy settings',
            Icons.lock_outlined,
            () {},
          ),
          _buildSettingsTile(
            'Two-Factor Auth',
            'Enable 2FA for security',
            Icons.security_outlined,
            () {},
          ),
          _buildSettingsTile(
            'Connected Apps',
            'Manage connected applications',
            Icons.apps_outlined,
            () {},
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.errorColor),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed ?? false) {
                  if (!mounted) return;
                  await context.read<AuthProvider>().signOut();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/signin', (route) => false);
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.errorColor),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.errorColor),
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildSettingsTile(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
    ) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderColor),
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primaryColor),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      );
    }
  }
