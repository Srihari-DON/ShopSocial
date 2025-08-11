import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../constants/strings.dart';
import '../../models/event.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/event_vm.dart';
import '../../viewmodels/group_vm.dart';
import '../../viewmodels/home_vm.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar.dart';
import '../../widgets/event_card.dart';
import '../../widgets/group_card.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Load data when the tab is created
    Future.microtask(() {
      ref.read(homeVMProvider.notifier).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeVMProvider);
    final user = ref.watch(authVMProvider).currentUser;
    final groupsState = ref.watch(groupVMProvider);
    final eventsState = ref.watch(eventVMProvider);
    
    // Get users for event creators
    Map<String, User> usersMap = {};
    if (user != null) {
      usersMap[user.id] = user;
    }
    
    // Show loading state
    if (homeState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality not implemented in demo')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications not implemented in demo')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(homeVMProvider.notifier).loadHomeData();
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (user != null) ...[
              // Welcome message
              Text(
                'Hello, ${user.name}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Welcome to ShopSocial',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            
            // My Groups section
            _buildSectionHeader(
              title: 'My Groups',
              actionLabel: 'See All',
              onActionTap: () {
                // In a real app, this would navigate to all groups
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All groups screen not implemented in demo')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Groups list
            if (groupsState.groups.isEmpty)
              _buildEmptyState(
                'No groups yet',
                'Join or create a group to get started',
                Icons.group_outlined,
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: groupsState.groups.length,
                  itemBuilder: (context, index) {
                    final group = groupsState.groups[index];
                    return SizedBox(
                      width: 100,
                      child: Card(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          side: BorderSide(
                            color: AppColors.outline,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.push('/group/${group.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Avatar(
                                  imageUrl: group.imageUrl,
                                  name: group.name,
                                  size: AvatarSize.medium,
                                  shape: AvatarShape.rounded,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  group.name,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            
            // Upcoming Events section
            _buildSectionHeader(
              title: 'Upcoming Events',
              actionLabel: 'See All',
              onActionTap: () {
                // Navigate to calendar tab
                setState(() {
                  context.go('/calendar');
                });
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Events list
            if (eventsState.events.isEmpty)
              _buildEmptyState(
                'No upcoming events',
                'Create an event to get started',
                Icons.event_outlined,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: eventsState.events.length > 3 ? 3 : eventsState.events.length,
                itemBuilder: (context, index) {
                  final event = eventsState.events[index];
                  return EventCard(
                    event: event,
                    creator: user ?? User(id: '1', name: 'User', email: 'user@example.com'),
                    onTap: () => context.push('/event/${event.id}'),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.lg),
            
            // Recently Active Groups
            _buildSectionHeader(
              title: 'Recently Active',
              actionLabel: 'See All',
              onActionTap: () {
                // In a real app, this would navigate to all groups
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All groups screen not implemented in demo')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Active groups list
            if (groupsState.groups.isEmpty)
              _buildEmptyState(
                'No active groups',
                'Join or create a group to get started',
                Icons.group_outlined,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupsState.groups.length > 2 ? 2 : groupsState.groups.length,
                itemBuilder: (context, index) {
                  final group = groupsState.groups[index];
                  return GroupCard(
                    group: group,
                    onTap: () => context.push('/group/${group.id}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: AppColors.outline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
