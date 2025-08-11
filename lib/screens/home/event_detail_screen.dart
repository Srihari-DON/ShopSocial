import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../models/event.dart';
import '../../models/event_option.dart';
import '../../models/user.dart';
import '../../viewmodels/event_vm.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  
  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  ResponseType _selectedResponse = ResponseType.maybe;
  
  @override
  void initState() {
    super.initState();
    // Load event details
    Future.microtask(() {
      ref.read(eventVMProvider.notifier).loadEventDetails(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventVMProvider);
    
    // Find current event
    final event = eventsState.events.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => Event(
        id: widget.eventId,
        name: 'Loading...',
        groupId: '',
        createdById: '',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    
    // Check if the event is loading
    if (eventsState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Mock creator for demo
    final creator = User(
      id: event.createdById,
      name: 'Event Creator',
      email: 'creator@example.com',
    );
    
    // Mock attendees for demo
    final attendees = [
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
    
    // Format dates
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');
    
    final formattedDate = dateFormat.format(event.startTime);
    final formattedStartTime = timeFormat.format(event.startTime);
    final formattedEndTime = timeFormat.format(event.endTime);
    final formattedTimeRange = '$formattedStartTime - $formattedEndTime';
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with event image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.name),
              background: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.secondary.withOpacity(0.7),
                      child: Center(
                        child: Icon(
                          Icons.event,
                          size: 64,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share event not implemented in demo'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showEventOptions(context, event);
                },
              ),
            ],
          ),
          
          // Event content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time
                  Card(
                    elevation: 0,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.sm),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  event.startTime.day.toString(),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM').format(event.startTime),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  formattedTimeRange,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month_outlined),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Add to calendar not implemented in demo'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Location
                  if (event.location != null && event.location!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(event.location!),
                      subtitle: const Text('Tap to view on map'),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Maps integration not implemented in demo'),
                          ),
                        );
                      },
                    ),
                  
                  // Description
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'About this event',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      event.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Creator
                  Row(
                    children: [
                      Avatar(
                        imageUrl: creator.profileImageUrl,
                        name: creator.name,
                        size: AvatarSize.small,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created by',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            creator.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Responses
                  Text(
                    'Your Response',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResponseButton(
                          context: context,
                          type: ResponseType.going,
                          icon: Icons.check_circle_outline,
                          label: 'Going',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildResponseButton(
                          context: context,
                          type: ResponseType.maybe,
                          icon: Icons.help_outline,
                          label: 'Maybe',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildResponseButton(
                          context: context,
                          type: ResponseType.notGoing,
                          icon: Icons.cancel_outlined,
                          label: 'Not Going',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Options (if any)
                  if (event.options != null && event.options!.isNotEmpty) ...[
                    Text(
                      'Options',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...event.options!.map((option) => _buildEventOption(context, option)),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  
                  // Attendees
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendees (${attendees.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('View all attendees not implemented in demo'),
                            ),
                          );
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: attendees.length,
                      itemBuilder: (context, index) {
                        final attendee = attendees[index];
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Column(
                            children: [
                              Avatar(
                                imageUrl: attendee.profileImageUrl,
                                name: attendee.name,
                                size: AvatarSize.medium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                attendee.name.split(' ')[0],
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton(
            onPressed: () {
              context.push('/chat/${event.groupId}');
            },
            label: 'Group Chat',
            variant: AppButtonVariant.primary,
            icon: Icons.chat_bubble_outline,
          ),
        ),
      ),
    );
  }
  
  Widget _buildResponseButton({
    required BuildContext context,
    required ResponseType type,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedResponse == type;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedResponse = type;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? _getColorForResponseType(type)
            : Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.grey[800],
        foregroundColor: isSelected
            ? Colors.white
            : _getColorForResponseType(type),
        side: BorderSide(
          color: _getColorForResponseType(type),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
  
  Color _getColorForResponseType(ResponseType type) {
    switch (type) {
      case ResponseType.going:
        return AppColors.success;
      case ResponseType.maybe:
        return AppColors.warning;
      case ResponseType.notGoing:
        return AppColors.danger;
    }
  }
  
  Widget _buildEventOption(BuildContext context, EventOption option) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        side: BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForOptionType(option.type),
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  option.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            if (option.description != null && option.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                option.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Voted for option: ${option.name}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Vote'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForOptionType(String type) {
    switch (type) {
      case 'location':
        return Icons.location_on_outlined;
      case 'date':
        return Icons.calendar_today_outlined;
      case 'time':
        return Icons.access_time;
      case 'activity':
        return Icons.emoji_events_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
  
  void _showEventOptions(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Event'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit event not implemented in demo'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share Event'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share event not implemented in demo'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Add to Calendar'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add to calendar not implemented in demo'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Set Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Set reminder not implemented in demo'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.danger),
                title: Text(
                  'Delete Event',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteEventConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showDeleteEventConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event?'),
          content: const Text(
            'Are you sure you want to delete this event? This action cannot be undone.',
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
                    content: Text('Delete event not implemented in demo'),
                  ),
                );
                // Navigate back
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

enum ResponseType {
  going,
  maybe,
  notGoing,
}
