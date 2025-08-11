class Group {
  final String id;
  final String name;
  final String description;
  final String privacy; // 'public'|'private'|'invite'
  final List<String> memberIds;
  final String? ownerId;
  final DateTime createdAt = DateTime.now();
  
  // Add aliases for property names used in the app
  String get imageUrl => 'https://picsum.photos/seed/$id/300/300';
  
  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.privacy,
    required this.memberIds,
    this.ownerId,
  });
  
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      privacy: json['privacy'] as String,
      memberIds: List<String>.from(json['memberIds']),
      ownerId: json['ownerId'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'privacy': privacy,
      'memberIds': memberIds,
      'ownerId': ownerId,
    };
  }
}
