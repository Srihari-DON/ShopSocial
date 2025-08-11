import '../models/event.dart';
import '../models/group.dart';
import '../services/i_event_service.dart';
import '../services/i_group_service.dart';

class EventRepository {
  final IEventService _eventService;
  final IGroupService _groupService;
  
  EventRepository(this._eventService, this._groupService);
  
  Future<List<Event>> fetchUpcomingEvents({String? groupId}) {
    return _eventService.fetchUpcomingEvents(groupId: groupId);
  }
  
  Future<Event> getEventById(String id) {
    return _eventService.getEventById(id);
  }
  
  Future<Event> createEvent(Event event) {
    return _eventService.createEvent(event);
  }
  
  Future<void> voteOption(String eventId, String optionId, String userId) {
    return _eventService.voteOption(eventId, optionId, userId);
  }
  
  Future<void> rsvp(String eventId, String userId, RSVPStatus status) {
    return _eventService.rsvp(eventId, userId, status);
  }
  
  Future<void> cancelEvent(String eventId) {
    return _eventService.cancelEvent(eventId);
  }
  
  Future<Event> finalizeEventDate(String eventId, String optionId) {
    return _eventService.finalizeEventDate(eventId, optionId);
  }
  
  Future<Event> updateEvent(String eventId, Map<String, dynamic> data) {
    return _eventService.updateEvent(eventId, data);
  }
  
  // Helper method to get group information for an event
  Future<Group> getEventGroup(String eventId) async {
    final event = await getEventById(eventId);
    return _groupService.getGroupById(event.groupId);
  }
}
