import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/group.dart';
import '../models/user.dart';
import '../repositories/group_repository.dart';
import '../repositories/user_repository.dart';
import '../services/group_service_mock.dart';
import 'auth_vm.dart';

// Home state
class HomeState {
  final List<Group> userGroups;
  final bool isLoadingGroups;
  final String? groupsError;
  
  HomeState({
    this.userGroups = const [],
    this.isLoadingGroups = false,
    this.groupsError,
  });
  
  HomeState copyWith({
    List<Group>? userGroups,
    bool? isLoadingGroups,
    String? groupsError,
  }) {
    return HomeState(
      userGroups: userGroups ?? this.userGroups,
      isLoadingGroups: isLoadingGroups ?? this.isLoadingGroups,
      groupsError: groupsError,
    );
  }
}

// Home ViewModel
class HomeVM extends StateNotifier<HomeState> {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final User? _currentUser;
  
  HomeVM(this._groupRepository, this._userRepository, this._currentUser)
      : super(HomeState()) {
    if (_currentUser != null) {
      fetchUserGroups();
    }
  }
  
  Future<void> fetchUserGroups() async {
    if (_currentUser == null) return;
    
    state = state.copyWith(isLoadingGroups: true);
    
    try {
      final groups = await _groupRepository.fetchUserGroups(_currentUser!.id);
      state = state.copyWith(
        userGroups: groups,
        isLoadingGroups: false,
        groupsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingGroups: false,
        groupsError: e.toString(),
      );
    }
  }
  
  Future<Group> createGroup(Group group) async {
    state = state.copyWith(isLoadingGroups: true);
    
    try {
      final newGroup = await _groupRepository.createGroup(group);
      state = state.copyWith(
        userGroups: [...state.userGroups, newGroup],
        isLoadingGroups: false,
        groupsError: null,
      );
      return newGroup;
    } catch (e) {
      state = state.copyWith(
        isLoadingGroups: false,
        groupsError: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> refreshData() async {
    await fetchUserGroups();
  }
}

// Providers
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(GroupServiceMock());
});

final homeVMProvider = StateNotifierProvider<HomeVM, HomeState>((ref) {
  final groupRepository = ref.watch(groupRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final authState = ref.watch(authVMProvider);
  
  return HomeVM(
    groupRepository,
    userRepository,
    authState.currentUser,
  );
});
