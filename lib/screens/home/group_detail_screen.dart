import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../models/event.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../viewmodels/event_vm.dart';
import '../../viewmodels/group_vm.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_segmented_control.dart';
import '../../widgets/avatar.dart';
import '../../widgets/event_card.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  
  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  String _activeTab = 'events';
  
  @override
  void initState() {
    super.initState();
    
    // Load group details and events
    Future.microtask(() async {
      await ref.read(groupVMProvider.notifier).loadGroupDetails(widget.groupId);
      await ref.read(eventVMProvider.notifier).loadEventsForGroup(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupVMProvider);
    final eventsState = ref.watch(eventVMProvider);
    
    // Find current group
    final group = groupState.groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(
        id: widget.groupId,
        name: 'Loading...',
        memberIds: [],
        createdAt: DateTime.now(),
      ),
    );
    
    // Filter events for this group
    final groupEvents = eventsState.events
        .where((event) => event.groupId == widget.groupId)
        .toList();
    
    return Scaffold(
      body: groupState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // App bar with group image
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(group.name),
                    background: group.imageUrl != null && group.imageUrl!.isNotEmpty
                        ? Image.network(
                            group.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.primary.withOpacity(0.7),
                            child: Center(
                              child: Icon(
                                Icons.group,
                                size: 64,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Show group options
                        _showGroupOptions(context, group);
                      },
                    ),
                  ],
                ),
                
                // Group content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group description
                      if (group.description != null && group.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            group.description!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      
                      // Group stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              context: context,
                              label: 'Members',
                              value: group.memberIds.length.toString(),
                              icon: Icons.people_outline,
                            ),
                            _buildStatCard(
                              context: context,
                              label: 'Events',
                              value: groupEvents.length.toString(),
                              icon: Icons.event_outlined,
                            ),
                            _buildStatCard(
                              context: context,
                              label: 'Expenses',
                              value: '0',
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(height: 32),
                      
                      // Tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: AppSegmentedControl<String>(
                          selectedValue: _activeTab,
                          options: const [
                            AppSegmentOption(
                              value: 'events',
                              label: 'Events',
                              icon: Icons.event,
                            ),
                            AppSegmentOption(
                              value: 'members',
                              label: 'Members',
                              icon: Icons.people,
                            ),
                            AppSegmentOption(
                              value: 'expenses',
                              label: 'Expenses',
                              icon: Icons.account_balance_wallet,
                            ),
                          ],
                          onValueChanged: (value) {
                            setState(() {
                              _activeTab = value;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Tab content
                      if (_activeTab == 'events')
                        _buildEventsTab(context, groupEvents)
                      else if (_activeTab == 'members')
                        _buildMembersTab(context, group)
                      else
                        _buildExpensesTab(context),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show create options based on active tab
          if (_activeTab == 'events') {
            context.push('/calendar/create?groupId=${widget.groupId}');
          } else if (_activeTab == 'members') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add members not implemented in demo'),
              ),
            );
          } else if (_activeTab == 'expenses') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add expense not implemented in demo'),
              ),
            );
          }
        },
        backgroundColor: AppColors.primary,
        child: Icon(
          _activeTab == 'events'
              ? Icons.add_circle_outline
              : _activeTab == 'members'
                  ? Icons.person_add_alt
                  : Icons.add_card,
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          side: BorderSide(color: AppColors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs / 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEventsTab(BuildContext context, List<Event> events) {
    // Mock creator for demo
    final mockCreator = User(
      id: '1',
      name: 'Demo User',
      email: 'user@example.com',
    );
    
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No Events Yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Create an event for this group',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                onPressed: () {
                  context.push('/calendar/create?groupId=${widget.groupId}');
                },
                label: 'Create Event',
                variant: AppButtonVariant.primary,
                icon: Icons.add_circle_outline,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(
          event: events[index],
          creator: mockCreator,
          onTap: () => context.push('/event/${events[index].id}'),
        );
      },
    );
  }
  
  Widget _buildMembersTab(BuildContext context, Group group) {
    // Mock members for demo
    final List<User> mockMembers = [
      User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      ),
      User(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      ),
      User(
        id: '3',
        name: 'Mike Johnson',
        email: 'mike@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group Members (${mockMembers.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite members not implemented in demo'),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Invite'),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.xs),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockMembers.length,
          itemBuilder: (context, index) {
            final member = mockMembers[index];
            
            return ListTile(
              leading: Avatar(
                imageUrl: member.profileImageUrl,
                name: member.name,
                size: AvatarSize.medium,
              ),
              title: Text(member.name),
              subtitle: Text(member.email),
              trailing: index == 0
                  ? Chip(
                      label: const Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    )
                  : null,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('View ${member.name}\'s profile'),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildExpensesTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No Expenses Yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add expenses and split costs with your group',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add expense not implemented in demo'),
                  ),
                );
              },
              label: 'Add Expense',
              variant: AppButtonVariant.primary,
              icon: Icons.add_card,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showGroupOptions(BuildContext context, Group group) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Group'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit group not implemented in demo'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share Group'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share group not implemented in demo'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message_outlined),
                title: const Text('Group Chat'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to group chat
                  context.push('/chat/${group.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Mute Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mute notifications not implemented in demo'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: AppColors.danger),
                title: Text(
                  'Leave Group',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLeaveGroupConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showLeaveGroupConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Group?'),
          content: const Text(
            'Are you sure you want to leave this group? You will no longer have access to group events, chats, and expenses.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leave group not implemented in demo'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: const Text('Leave Group'),
            ),
          ],
        );
      },
    );
  }
}
