import '../models/group.dart';
import '../services/i_group_service.dart';

class GroupRepository {
  final IGroupService _groupService;
  
  GroupRepository(this._groupService);
  
  Future<List<Group>> fetchUserGroups(String userId) {
    return _groupService.fetchUserGroups(userId);
  }
  
  Future<Group> getGroupById(String id) {
    return _groupService.getGroupById(id);
  }
  
  Future<Group> createGroup(Group group) {
    return _groupService.createGroup(group);
  }
  
  Future<Group> updateGroup(String id, Map<String, dynamic> data) {
    return _groupService.updateGroup(id, data);
  }
  
  Future<void> deleteGroup(String id) {
    return _groupService.deleteGroup(id);
  }
  
  Future<Group> addMember(String groupId, String userId) {
    return _groupService.addMember(groupId, userId);
  }
  
  Future<Group> removeMember(String groupId, String userId) {
    return _groupService.removeMember(groupId, userId);
  }
  
  Future<Group> transferOwnership(String groupId, String newOwnerId) {
    return _groupService.transferOwnership(groupId, newOwnerId);
  }
}
