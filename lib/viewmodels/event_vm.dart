import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/event.dart';
import '../models/event_option.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../repositories/event_repository.dart';
import '../repositories/group_repository.dart';
import '../repositories/user_repository.dart';
import '../services/event_service_mock.dart';
import '../services/i_event_service.dart';
import 'auth_vm.dart';
import 'home_vm.dart';

// Event state
class EventState {
  final Event? event;
  final Group? group;
  final List<User> participants;
  final bool isLoading;
  final String? error;
  final RSVPStatus? userRSVPStatus;
  final bool isCurrentUserCreator;
  final bool isCurrentUserGroupOwner;
  
  EventState({
    this.event,
    this.group,
    this.participants = const [],
    this.isLoading = false,
    this.error,
    this.userRSVPStatus,
    this.isCurrentUserCreator = false,
    this.isCurrentUserGroupOwner = false,
  });
  
  EventState copyWith({
    Event? event,
    Group? group,
    List<User>? participants,
    bool? isLoading,
    String? error,
    RSVPStatus? userRSVPStatus,
    bool? isCurrentUserCreator,
    bool? isCurrentUserGroupOwner,
  }) {
    return EventState(
      event: event ?? this.event,
      group: group ?? this.group,
      participants: participants ?? this.participants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userRSVPStatus: userRSVPStatus ?? this.userRSVPStatus,
      isCurrentUserCreator: isCurrentUserCreator ?? this.isCurrentUserCreator,
      isCurrentUserGroupOwner: isCurrentUserGroupOwner ?? this.isCurrentUserGroupOwner,
    );
  }
}

// Event ViewModel
class EventVM extends StateNotifier<EventState> {
  final EventRepository _eventRepository;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final String eventId;
  final User? _currentUser;
  
  EventVM(
    this._eventRepository,
    this._groupRepository,
    this._userRepository,
    this.eventId,
    this._currentUser,
  ) : super(EventState()) {
    fetchEventDetails();
  }
  
  Future<void> fetchEventDetails() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final event = await _eventRepository.getEventById(eventId);
      final group = await _groupRepository.getGroupById(event.groupId);
      
      // Get all unique participant IDs from all options
      final participantIds = <String>{};
      for (final option in event.options) {
        participantIds.addAll(option.votes);
      }
      final participants = await _userRepository.getUsersByIds(participantIds.toList());
      
      final isCreator = _currentUser != null && event.createdBy == _currentUser!.id;
      final isGroupOwner = _currentUser != null && group.ownerId == _currentUser!.id;
      
      state = state.copyWith(
        event: event,
        group: group,
        participants: participants,
        isLoading: false,
        error: null,
        isCurrentUserCreator: isCreator,
        isCurrentUserGroupOwner: isGroupOwner,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> voteForOption(String optionId) async {
    if (_currentUser == null || state.event == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      await _eventRepository.voteOption(eventId, optionId, _currentUser!.id);
      await fetchEventDetails(); // Refresh event data
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> updateRSVP(RSVPStatus status) async {
    if (_currentUser == null || state.event == null) return;
    
    state = state.copyWith(isLoading: true, userRSVPStatus: status);
    
    try {
      await _eventRepository.rsvp(eventId, _currentUser!.id, status);
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        userRSVPStatus: state.userRSVPStatus, // Revert if there was an error
      );
    }
  }
  
  Future<void> cancelEvent() async {
    if (!state.isCurrentUserCreator && !state.isCurrentUserGroupOwner) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      await _eventRepository.cancelEvent(eventId);
      await fetchEventDetails(); // Refresh event data
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> finalizeEventDate(String optionId) async {
    if (!state.isCurrentUserCreator && !state.isCurrentUserGroupOwner) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedEvent = await _eventRepository.finalizeEventDate(eventId, optionId);
      state = state.copyWith(
        event: updatedEvent,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> updateEvent(Map<String, dynamic> data) async {
    if (!state.isCurrentUserCreator && !state.isCurrentUserGroupOwner) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedEvent = await _eventRepository.updateEvent(eventId, data);
      state = state.copyWith(
        event: updatedEvent,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Helper method to check if user has voted for a specific option
  bool hasUserVotedFor(String optionId) {
    if (_currentUser == null || state.event == null) return false;
    
    final option = state.event!.options.firstWhere(
      (option) => option.id == optionId,
      orElse: () => EventOption(
        id: '',
        optionText: '',
        startsAt: DateTime.now(),
        votes: [],
      ),
    );
    
    return option.votes.contains(_currentUser!.id);
  }
  
  // Get vote count for an option
  int getVoteCount(String optionId) {
    if (state.event == null) return 0;
    
    final option = state.event!.options.firstWhere(
      (option) => option.id == optionId,
      orElse: () => EventOption(
        id: '',
        optionText: '',
        startsAt: DateTime.now(),
        votes: [],
      ),
    );
    
    return option.votes.length;
  }
  
  // Get total votes across all options
  int get totalVotes {
    if (state.event == null) return 0;
    
    return state.event!.options.fold<int>(
      0,
      (sum, option) => sum + option.votes.length,
    );
  }
  
  // Get vote percentage for an option
  double getVotePercentage(String optionId) {
    final total = totalVotes;
    if (total == 0) return 0;
    
    return getVoteCount(optionId) / total * 100;
  }
}

// Provider factory for EventVM instances
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final eventService = EventServiceMock();
  final groupRepository = ref.watch(groupRepositoryProvider);
  return EventRepository(eventService, groupRepository);
});

final eventVMProvider = StateNotifierProvider.family<EventVM, EventState, String>((ref, eventId) {
  final eventRepository = ref.watch(eventRepositoryProvider);
  final groupRepository = ref.watch(groupRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final authState = ref.watch(authVMProvider);
  
  return EventVM(
    eventRepository,
    groupRepository,
    userRepository,
    eventId,
    authState.currentUser,
  );
});
