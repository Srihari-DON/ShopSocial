import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../constants/strings.dart';
import '../../viewmodels/auth_vm.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authVMProvider);
    final user = authState.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings not implemented in demo'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Avatar
                Avatar(
                  imageUrl: user.profileImageUrl,
                  name: user.name,
                  size: AvatarSize.extraLarge,
                  showBorder: true,
                  borderColor: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Name
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                
                // Email
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Edit profile button
                AppButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile not implemented in demo'),
                      ),
                    );
                  },
                  label: 'Edit Profile',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.edit,
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Profile sections
          _buildSection(
            title: 'Your Activity',
            items: [
              _buildMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Your Orders',
                subtitle: 'View and manage your orders',
              ),
              _buildMenuItem(
                icon: Icons.history,
                title: 'Purchase History',
                subtitle: 'View your purchase history',
              ),
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'Saved Items',
                subtitle: 'Items you\'ve saved',
              ),
            ],
          ),
          
          const Divider(),
          
          _buildSection(
            title: 'Groups & Events',
            items: [
              _buildMenuItem(
                icon: Icons.group_outlined,
                title: 'Manage Groups',
                subtitle: 'View and manage your groups',
              ),
              _buildMenuItem(
                icon: Icons.event_outlined,
                title: 'Your Events',
                subtitle: 'Events you\'ve created or joined',
              ),
              _buildMenuItem(
                icon: Icons.people_outline,
                title: 'Friends',
                subtitle: 'Manage your friends',
              ),
            ],
          ),
          
          const Divider(),
          
          _buildSection(
            title: 'Account',
            items: [
              _buildMenuItem(
                icon: Icons.account_circle_outlined,
                title: 'Account Settings',
                subtitle: 'Manage your account settings',
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notification Preferences',
                subtitle: 'Manage your notification settings',
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: 'Manage your privacy settings',
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help with your account',
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Learn more about ${AppStrings.appName}',
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              onPressed: () async {
                await ref.read(authVMProvider.notifier).logout();
              },
              label: 'Log Out',
              variant: AppButtonVariant.text,
              icon: Icons.exit_to_app,
              iconPosition: IconPosition.start,
              textColor: AppColors.danger,
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title not implemented in demo'),
          ),
        );
      },
    );
  }
}
