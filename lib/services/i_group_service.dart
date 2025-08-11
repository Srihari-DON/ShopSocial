import '../models/group.dart';

abstract class IGroupService {
  Future<List<Group>> fetchUserGroups(String userId);
  Future<Group> getGroupById(String id);
  Future<Group> createGroup(Group group);
  Future<Group> updateGroup(String id, Map<String, dynamic> data);
  Future<void> deleteGroup(String id);
  Future<Group> addMember(String groupId, String userId);
  Future<Group> removeMember(String groupId, String userId);
  Future<Group> transferOwnership(String groupId, String newOwnerId);
}
