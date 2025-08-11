import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';

class CreateEventWizard extends ConsumerStatefulWidget {
  final String? groupId;
  
  const CreateEventWizard({
    super.key,
    this.groupId,
  });

  @override
  ConsumerState<CreateEventWizard> createState() => _CreateEventWizardState();
}

class _CreateEventWizardState extends ConsumerState<CreateEventWizard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // For demo, just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Navigate back after "creating" event
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
        ),
      );
      context.go('/calendar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Event name
            AppTextField(
              label: 'Event Name',
              hint: 'Enter event name',
              controller: _nameController,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Event description
            AppTextField(
              label: 'Description',
              hint: 'Enter event description (optional)',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Event location
            AppTextField(
              label: 'Location',
              hint: 'Enter event location (optional)',
              controller: _locationController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Date and time picker cards
            Text(
              'Date and Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Start date/time
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                side: BorderSide(color: AppColors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              
                              if (date != null) {
                                setState(() {
                                  _startDate = date;
                                  if (_endDate.isBefore(_startDate)) {
                                    _endDate = _startDate;
                                  }
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                              ),
                              child: Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: AppSpacing.sm),
                        
                        // Time picker
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                              );
                              
                              if (time != null) {
                                setState(() {
                                  _startTime = time;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.access_time),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                              ),
                              child: Text(
                                '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // End date/time
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                side: BorderSide(color: AppColors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: _startDate,
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              
                              if (date != null) {
                                setState(() {
                                  _endDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                              ),
                              child: Text(
                                '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: AppSpacing.sm),
                        
                        // Time picker
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _endTime,
                              );
                              
                              if (time != null) {
                                setState(() {
                                  _endTime = time;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.access_time),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                              ),
                              child: Text(
                                '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // More options section (simplified for demo)
            Text(
              'More Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Invite Attendees'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invite attendees not implemented in demo'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Add Reminder'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add reminder not implemented in demo'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.how_to_vote_outlined),
              title: const Text('Add Poll or Options'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add poll not implemented in demo'),
                  ),
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton(
            onPressed: _createEvent,
            label: 'Create Event',
            isLoading: _isLoading,
            variant: AppButtonVariant.primary,
          ),
        ),
      ),
    );
  }
}
