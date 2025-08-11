import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../models/group.dart';
import 'data_service.dart';
import 'widgets.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isLoading = false;
  Event? _event;
  Group? _group;
  List<User> _attendees = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dataRepo = ref.read(dataRepositoryProvider);
      
      final event = await dataRepo.getEventById(widget.eventId);
      final group = await dataRepo.getGroupById(event.groupId);
      final allUsers = await dataRepo.getUsers();
      // For demo purposes, we'll show the creator as the only attendee
      final attendees = allUsers.where((user) => user.id == event.createdBy).toList();
      
      setState(() {
        _event = event;
        _group = group;
        _attendees = attendees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading event: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_event?.title ?? 'Event Details'),
      ),
      body: _isLoading || _event == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event header
                  if (_event!.imageUrl != null && _event!.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _event!.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  Text(
                    _event!.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  
                  if (_group != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Avatar(
                          imageUrl: _group!.imageUrl,
                          name: _group!.name,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _group!.name,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  
                  // Event details
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date & Time'),
                    subtitle: Text(_formatDate(_event!.startsAt ?? DateTime.now())),
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Location'),
                    subtitle: Text(_event!.options.isNotEmpty ? _event!.options[0].optionText : "No location specified"),
                  ),
                  
                  if (_event!.description.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Description'),
                      subtitle: Text(_event!.description),
                    ),
                  
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Attendees
                  Text(
                    'Attendees (${_attendees.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _attendees.map((attendee) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Avatar(
                            imageUrl: attendee.avatarUrl,
                            name: attendee.name,
                            size: 48,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            attendee.name.split(' ')[0],
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  AppButton(
                    text: 'I\'m going',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Response recorded!')),
                      );
                    },
                    icon: Icons.check,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  AppButton(
                    text: 'Maybe',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Response recorded!')),
                      );
                    },
                    isOutlined: true,
                    icon: Icons.help_outline,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  AppButton(
                    text: 'Can\'t go',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Response recorded!')),
                      );
                    },
                    isOutlined: true,
                    icon: Icons.close,
                  ),
                ],
              ),
            ),
    );
  }
}
