import '../models/event.dart';

enum RSVPStatus {
  going,
  maybe,
  notGoing,
}

abstract class IEventService {
  Future<List<Event>> fetchUpcomingEvents({String? groupId});
  Future<Event> getEventById(String id);
  Future<Event> createEvent(Event event);
  Future<void> voteOption(String eventId, String optionId, String userId);
  Future<void> rsvp(String eventId, String userId, RSVPStatus status);
  Future<void> cancelEvent(String eventId);
  Future<Event> finalizeEventDate(String eventId, String optionId);
  Future<Event> updateEvent(String eventId, Map<String, dynamic> data);
}
