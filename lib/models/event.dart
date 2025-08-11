import 'event_option.dart';

class Event {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final List<EventOption> options;
  final DateTime? startsAt; // chosen final time if locked
  final String? coverImage;
  final String createdBy;
  final bool isCancelled;
  
  // Add aliases for property names used in the app
  String get name => title;
  DateTime get startTime => startsAt ?? DateTime.now();
  DateTime get endTime => startsAt != null ? startsAt!.add(Duration(hours: 2)) : DateTime.now().add(Duration(hours: 2));
  String? get imageUrl => coverImage;
  
  Event({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.options,
    this.startsAt,
    this.coverImage,
    required this.createdBy,
    this.isCancelled = false,
  });
  
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      options: (json['options'] as List)
          .map((option) => EventOption.fromJson(option as Map<String, dynamic>))
          .toList(),
      startsAt: json['startsAt'] != null
          ? DateTime.parse(json['startsAt'] as String)
          : null,
      coverImage: json['coverImage'] as String?,
      createdBy: json['createdBy'] as String,
      isCancelled: json['isCancelled'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'options': options.map((option) => option.toJson()).toList(),
      'startsAt': startsAt?.toIso8601String(),
      'coverImage': coverImage,
      'createdBy': createdBy,
      'isCancelled': isCancelled,
    };
  }
}
