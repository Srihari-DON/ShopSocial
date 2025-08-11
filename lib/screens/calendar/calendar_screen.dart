import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../viewmodels/event_vm.dart';
import '../../widgets/app_segmented_control.dart';
import '../../widgets/event_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  String _viewType = 'upcoming';
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Load events when the screen is created
    Future.microtask(() {
      ref.read(eventVMProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventVMProvider);
    
    // Filter events based on view type
    List<Event> filteredEvents = [];
    if (_viewType == 'upcoming') {
      filteredEvents = eventsState.events
          .where((event) => event.startTime.isAfter(DateTime.now()))
          .toList();
    } else if (_viewType == 'past') {
      filteredEvents = eventsState.events
          .where((event) => event.startTime.isBefore(DateTime.now()))
          .toList();
    } else {
      // All events
      filteredEvents = eventsState.events;
    }
    
    // Sort by date
    filteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Group events by date
    Map<String, List<Event>> eventsByDate = {};
    for (var event in filteredEvents) {
      final dateString = DateFormat('yyyy-MM-dd').format(event.startTime);
      if (!eventsByDate.containsKey(dateString)) {
        eventsByDate[dateString] = [];
      }
      eventsByDate[dateString]!.add(event);
    }
    
    // Mock creator user for demo purposes
    final mockCreator = User(
      id: '1',
      name: 'Demo User',
      email: 'user@example.com',
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // View type segmented control
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSegmentedControl<String>(
              selectedValue: _viewType,
              options: const [
                AppSegmentOption(
                  value: 'upcoming',
                  label: 'Upcoming',
                  icon: Icons.upcoming,
                ),
                AppSegmentOption(
                  value: 'all',
                  label: 'All Events',
                  icon: Icons.calendar_view_month,
                ),
                AppSegmentOption(
                  value: 'past',
                  label: 'Past',
                  icon: Icons.history,
                ),
              ],
              onValueChanged: (value) {
                setState(() {
                  _viewType = value;
                });
              },
            ),
          ),
          
          // Events list
          Expanded(
            child: eventsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : eventsByDate.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: eventsByDate.length,
                        itemBuilder: (context, index) {
                          final date = eventsByDate.keys.elementAt(index);
                          final eventsForDate = eventsByDate[date]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date header
                              _buildDateHeader(DateTime.parse(date)),
                              
                              // Events for this date
                              ...eventsForDate.map((event) {
                                return EventCard(
                                  event: event,
                                  creator: mockCreator,
                                  onTap: () {
                                    // Navigate to event details
                                    Navigator.pushNamed(
                                      context,
                                      '/event/${event.id}',
                                    );
                                  },
                                );
                              }).toList(),
                              
                              // Divider after each date group except the last
                              if (index < eventsByDate.length - 1)
                                const Divider(height: AppSpacing.lg),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create event wizard
          Navigator.pushNamed(
            context,
            '/calendar/create',
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDateHeader(DateTime date) {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    
    String dateText;
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      dateText = 'Today';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      dateText = 'Tomorrow';
    } else {
      dateText = DateFormat('EEEE, MMMM d').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs / 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.xs),
          
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _viewType == 'upcoming'
                ? 'You have no upcoming events scheduled'
                : _viewType == 'past'
                    ? 'No past events to show'
                    : 'No events found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create event
              Navigator.pushNamed(context, '/calendar/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
        ],
      ),
    );
  }
}
