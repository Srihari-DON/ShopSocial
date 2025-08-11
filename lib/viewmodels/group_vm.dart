import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/group.dart';
import '../models/user.dart';
import '../repositories/group_repository.dart';
import '../repositories/user_repository.dart';
import 'auth_vm.dart';
import 'home_vm.dart';

// Group state
class GroupState {
  final Group? group;
  final List<User> members;
  final bool isLoading;
  final String? error;
  final bool isCurrentUserOwner;
  final bool isCurrentUserMember;
  
  GroupState({
    this.group,
    this.members = const [],
    this.isLoading = false,
    this.error,
    this.isCurrentUserOwner = false,
    this.isCurrentUserMember = false,
  });
  
  GroupState copyWith({
    Group? group,
    List<User>? members,
    bool? isLoading,
    String? error,
    bool? isCurrentUserOwner,
    bool? isCurrentUserMember,
  }) {
    return GroupState(
      group: group ?? this.group,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCurrentUserOwner: isCurrentUserOwner ?? this.isCurrentUserOwner,
      isCurrentUserMember: isCurrentUserMember ?? this.isCurrentUserMember,
    );
  }
}

// Group ViewModel
class GroupVM extends StateNotifier<GroupState> {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final String groupId;
  final User? _currentUser;
  
  GroupVM(
    this._groupRepository,
    this._userRepository,
    this.groupId,
    this._currentUser,
  ) : super(GroupState()) {
    fetchGroupDetails();
  }
  
  Future<void> fetchGroupDetails() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final group = await _groupRepository.getGroupById(groupId);
      final members = await _userRepository.getUsersByIds(group.memberIds);
      
      final isOwner = _currentUser != null && group.ownerId == _currentUser!.id;
      final isMember = _currentUser != null && group.memberIds.contains(_currentUser!.id);
      
      state = state.copyWith(
        group: group,
        members: members,
        isLoading: false,
        error: null,
        isCurrentUserOwner: isOwner,
        isCurrentUserMember: isMember,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> updateGroup(Map<String, dynamic> data) async {
    if (!state.isCurrentUserOwner || state.group == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedGroup = await _groupRepository.updateGroup(groupId, data);
      state = state.copyWith(
        group: updatedGroup,
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
  
  Future<void> addMember(String userId) async {
    if (!state.isCurrentUserOwner) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedGroup = await _groupRepository.addMember(groupId, userId);
      final updatedMembers = await _userRepository.getUsersByIds(updatedGroup.memberIds);
      
      state = state.copyWith(
        group: updatedGroup,
        members: updatedMembers,
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
  
  Future<void> removeMember(String userId) async {
    if (!state.isCurrentUserOwner) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedGroup = await _groupRepository.removeMember(groupId, userId);
      final updatedMembers = await _userRepository.getUsersByIds(updatedGroup.memberIds);
      
      state = state.copyWith(
        group: updatedGroup,
        members: updatedMembers,
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
  
  Future<void> leaveGroup() async {
    if (_currentUser == null || !state.isCurrentUserMember) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      await _groupRepository.removeMember(groupId, _currentUser!.id);
      
      state = state.copyWith(
        isLoading: false,
        error: null,
        isCurrentUserMember: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> joinGroup() async {
    if (_currentUser == null || state.isCurrentUserMember) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedGroup = await _groupRepository.addMember(groupId, _currentUser!.id);
      final updatedMembers = await _userRepository.getUsersByIds(updatedGroup.memberIds);
      
      state = state.copyWith(
        group: updatedGroup,
        members: updatedMembers,
        isLoading: false,
        error: null,
        isCurrentUserMember: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> transferOwnership(String newOwnerId) async {
    if (!state.isCurrentUserOwner) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedGroup = await _groupRepository.transferOwnership(groupId, newOwnerId);
      
      state = state.copyWith(
        group: updatedGroup,
        isLoading: false,
        error: null,
        isCurrentUserOwner: _currentUser?.id == newOwnerId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> deleteGroup() async {
    if (!state.isCurrentUserOwner) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      await _groupRepository.deleteGroup(groupId);
      
      state = state.copyWith(
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
}

// Provider factory for GroupVM instances
final groupVMProvider = StateNotifierProvider.family<GroupVM, GroupState, String>((ref, groupId) {
  final groupRepository = ref.watch(groupRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final authState = ref.watch(authVMProvider);
  
  return GroupVM(
    groupRepository,
    userRepository,
    groupId,
    authState.currentUser,
  );
});
