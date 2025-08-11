import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/group.dart';
import 'i_group_service.dart';

class GroupServiceMock implements IGroupService {
  late List<Group> _groups;
  
  GroupServiceMock() {
    _loadGroups();
  }
  
  Future<void> _loadGroups() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/mock_data/groups.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _groups = jsonList.map((json) => Group.fromJson(json)).toList();
    } catch (e) {
      // If file doesn't exist yet, create placeholder data
      _groups = [
        Group(
          id: 'g1',
          name: 'Movie Nights',
          description: 'Group for planning movie nights',
          privacy: 'public',
          memberIds: ['u1', 'u2', 'u3'],
          ownerId: 'u1',
        ),
        Group(
          id: 'g2',
          name: 'Weekend Trips',
          description: 'Planning weekend getaways',
          privacy: 'private',
          memberIds: ['u1', 'u2', 'u4'],
          ownerId: 'u2',
        ),
      ];
    }
  }
  
  @override
  Future<List<Group>> fetchUserGroups(String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    return _groups.where((group) => group.memberIds.contains(userId)).toList();
  }
  
  @override
  Future<Group> getGroupById(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    final group = _groups.firstWhere(
      (group) => group.id == id,
      orElse: () => throw Exception('Group not found'),
    );
    
    return group;
  }
  
  @override
  Future<Group> createGroup(Group group) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final newGroup = Group(
      id: 'g${_groups.length + 1}',
      name: group.name,
      description: group.description,
      privacy: group.privacy,
      memberIds: group.memberIds,
      ownerId: group.ownerId,
    );
    
    _groups.add(newGroup);
    return newGroup;
  }
  
  @override
  Future<Group> updateGroup(String id, Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final groupIndex = _groups.indexWhere((group) => group.id == id);
    if (groupIndex == -1) {
      throw Exception('Group not found');
    }
    
    final currentGroup = _groups[groupIndex];
    final updatedGroup = Group(
      id: currentGroup.id,
      name: data['name'] ?? currentGroup.name,
      description: data['description'] ?? currentGroup.description,
      privacy: data['privacy'] ?? currentGroup.privacy,
      memberIds: data['memberIds'] ?? currentGroup.memberIds,
      ownerId: data['ownerId'] ?? currentGroup.ownerId,
    );
    
    _groups[groupIndex] = updatedGroup;
    return updatedGroup;
  }
  
  @override
  Future<void> deleteGroup(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    _groups.removeWhere((group) => group.id == id);
  }
  
  @override
  Future<Group> addMember(String groupId, String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex == -1) {
      throw Exception('Group not found');
    }
    
    final currentGroup = _groups[groupIndex];
    
    if (currentGroup.memberIds.contains(userId)) {
      return currentGroup; // Member already in the group
    }
    
    final updatedMemberIds = List<String>.from(currentGroup.memberIds)..add(userId);
    final updatedGroup = Group(
      id: currentGroup.id,
      name: currentGroup.name,
      description: currentGroup.description,
      privacy: currentGroup.privacy,
      memberIds: updatedMemberIds,
      ownerId: currentGroup.ownerId,
    );
    
    _groups[groupIndex] = updatedGroup;
    return updatedGroup;
  }
  
  @override
  Future<Group> removeMember(String groupId, String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex == -1) {
      throw Exception('Group not found');
    }
    
    final currentGroup = _groups[groupIndex];
    
    if (currentGroup.ownerId == userId) {
      throw Exception('Cannot remove the owner from the group');
    }
    
    final updatedMemberIds = List<String>.from(currentGroup.memberIds)..remove(userId);
    final updatedGroup = Group(
      id: currentGroup.id,
      name: currentGroup.name,
      description: currentGroup.description,
      privacy: currentGroup.privacy,
      memberIds: updatedMemberIds,
      ownerId: currentGroup.ownerId,
    );
    
    _groups[groupIndex] = updatedGroup;
    return updatedGroup;
  }
  
  @override
  Future<Group> transferOwnership(String groupId, String newOwnerId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex == -1) {
      throw Exception('Group not found');
    }
    
    final currentGroup = _groups[groupIndex];
    
    if (!currentGroup.memberIds.contains(newOwnerId)) {
      throw Exception('New owner must be a member of the group');
    }
    
    final updatedGroup = Group(
      id: currentGroup.id,
      name: currentGroup.name,
      description: currentGroup.description,
      privacy: currentGroup.privacy,
      memberIds: currentGroup.memberIds,
      ownerId: newOwnerId,
    );
    
    _groups[groupIndex] = updatedGroup;
    return updatedGroup;
  }
}
