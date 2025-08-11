import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/event.dart';
import '../models/event_option.dart';
import 'i_event_service.dart';

class EventServiceMock implements IEventService {
  late List<Event> _events;
  final Map<String, RSVPStatus> _rsvpStatuses = {}; // eventId_userId -> status
  
  EventServiceMock() {
    _loadEvents();
  }
  
  Future<void> _loadEvents() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/mock_data/events.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _events = jsonList.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      // If file doesn't exist yet, create placeholder data
      _events = [
        Event(
          id: 'e1',
          groupId: 'g1',
          title: 'Movie Night: Marvel Marathon',
          description: 'Let\'s watch the best Marvel movies back to back!',
          options: [
            EventOption(
              id: 'o1',
              optionText: 'Saturday at my place',
              startsAt: DateTime.now().add(Duration(days: 3)),
              votes: ['u1', 'u3'],
            ),
            EventOption(
              id: 'o2',
              optionText: 'Sunday afternoon at Maya\'s',
              startsAt: DateTime.now().add(Duration(days: 4)),
              votes: ['u2'],
            ),
          ],
          createdBy: 'u1',
          coverImage: 'assets/images/marvel_cover.png',
        ),
        Event(
          id: 'e2',
          groupId: 'g2',
          title: 'Weekend Trip to the Mountains',
          description: 'Hiking and camping in the mountains',
          options: [
            EventOption(
              id: 'o3',
              optionText: 'Next weekend - Cascade Mountains',
              startsAt: DateTime.now().add(Duration(days: 10)),
              lat: 47.5423,
              lng: -121.8286,
              votes: ['u1', 'u2', 'u4'],
            ),
            EventOption(
              id: 'o4',
              optionText: 'Two weeks from now - Olympic National Park',
              startsAt: DateTime.now().add(Duration(days: 17)),
              lat: 47.8021,
              lng: -123.6044,
              votes: ['u3'],
            ),
          ],
          createdBy: 'u2',
          coverImage: 'assets/images/mountains_cover.png',
        ),
      ];
    }
  }
  
  @override
  Future<List<Event>> fetchUpcomingEvents({String? groupId}) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    if (groupId != null) {
      return _events
          .where((event) => event.groupId == groupId && !event.isCancelled)
          .toList();
    }
    
    return _events.where((event) => !event.isCancelled).toList();
  }
  
  @override
  Future<Event> getEventById(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    final event = _events.firstWhere(
      (event) => event.id == id,
      orElse: () => throw Exception('Event not found'),
    );
    
    return event;
  }
  
  @override
  Future<Event> createEvent(Event event) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    // Create new event with generated ID
    final newEvent = Event(
      id: 'e${_events.length + 1}',
      groupId: event.groupId,
      title: event.title,
      description: event.description,
      options: event.options.map((option) {
        return EventOption(
          id: option.id.isEmpty ? 'o${DateTime.now().millisecondsSinceEpoch}' : option.id,
          optionText: option.optionText,
          startsAt: option.startsAt,
          lat: option.lat,
          lng: option.lng,
          votes: option.votes,
        );
      }).toList(),
      startsAt: event.startsAt,
      coverImage: event.coverImage,
      createdBy: event.createdBy,
      isCancelled: false,
    );
    
    _events.add(newEvent);
    return newEvent;
  }
  
  @override
  Future<void> voteOption(String eventId, String optionId, String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) {
      throw Exception('Event not found');
    }
    
    final event = _events[eventIndex];
    final List<EventOption> updatedOptions = [];
    
    // Remove user's vote from all options
    for (final option in event.options) {
      if (option.id == optionId) {
        // Add vote to this option if not already voted
        final hasVoted = option.votes.contains(userId);
        final updatedVotes = List<String>.from(option.votes);
        if (!hasVoted) {
          updatedVotes.add(userId);
        }
        
        updatedOptions.add(EventOption(
          id: option.id,
          optionText: option.optionText,
          startsAt: option.startsAt,
          lat: option.lat,
          lng: option.lng,
          votes: updatedVotes,
        ));
      } else {
        // Remove vote from other options
        final updatedVotes = List<String>.from(option.votes)..remove(userId);
        updatedOptions.add(EventOption(
          id: option.id,
          optionText: option.optionText,
          startsAt: option.startsAt,
          lat: option.lat,
          lng: option.lng,
          votes: updatedVotes,
        ));
      }
    }
    
    // Update event with new options
    _events[eventIndex] = Event(
      id: event.id,
      groupId: event.groupId,
      title: event.title,
      description: event.description,
      options: updatedOptions,
      startsAt: event.startsAt,
      coverImage: event.coverImage,
      createdBy: event.createdBy,
      isCancelled: event.isCancelled,
    );
  }
  
  @override
  Future<void> rsvp(String eventId, String userId, RSVPStatus status) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    // Store RSVP status for this user and event
    _rsvpStatuses['${eventId}_${userId}'] = status;
  }
  
  @override
  Future<void> cancelEvent(String eventId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) {
      throw Exception('Event not found');
    }
    
    final event = _events[eventIndex];
    _events[eventIndex] = Event(
      id: event.id,
      groupId: event.groupId,
      title: event.title,
      description: event.description,
      options: event.options,
      startsAt: event.startsAt,
      coverImage: event.coverImage,
      createdBy: event.createdBy,
      isCancelled: true,
    );
  }
  
  @override
  Future<Event> finalizeEventDate(String eventId, String optionId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) {
      throw Exception('Event not found');
    }
    
    final event = _events[eventIndex];
    final selectedOption = event.options.firstWhere(
      (option) => option.id == optionId,
      orElse: () => throw Exception('Option not found'),
    );
    
    // Update event with selected startsAt date from option
    _events[eventIndex] = Event(
      id: event.id,
      groupId: event.groupId,
      title: event.title,
      description: event.description,
      options: event.options,
      startsAt: selectedOption.startsAt,
      coverImage: event.coverImage,
      createdBy: event.createdBy,
      isCancelled: event.isCancelled,
    );
    
    return _events[eventIndex];
  }
  
  @override
  Future<Event> updateEvent(String eventId, Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) {
      throw Exception('Event not found');
    }
    
    final event = _events[eventIndex];
    _events[eventIndex] = Event(
      id: event.id,
      groupId: data['groupId'] ?? event.groupId,
      title: data['title'] ?? event.title,
      description: data['description'] ?? event.description,
      options: data['options'] ?? event.options,
      startsAt: data['startsAt'] ?? event.startsAt,
      coverImage: data['coverImage'] ?? event.coverImage,
      createdBy: event.createdBy,
      isCancelled: data['isCancelled'] ?? event.isCancelled,
    );
    
    return _events[eventIndex];
  }
}
