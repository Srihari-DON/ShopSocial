enum EventOptionType {
  time,
  location,
  activity
}

class EventOption {
  final String id;
  final String optionText;
  final DateTime startsAt;
  final double? lat, lng;
  final List<String> votes; // userIds
  
  // Add aliases for property names used in the app
  String get name => optionText;
  String? get description => null;
  EventOptionType get type => EventOptionType.time;
  
  EventOption({
    required this.id,
    required this.optionText,
    required this.startsAt,
    this.lat,
    this.lng,
    required this.votes,
  });
  
  factory EventOption.fromJson(Map<String, dynamic> json) {
    return EventOption(
      id: json['id'] as String,
      optionText: json['optionText'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      lat: json['lat'] as double?,
      lng: json['lng'] as double?,
      votes: List<String>.from(json['votes'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'optionText': optionText,
      'startsAt': startsAt.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'votes': votes,
    };
  }
}
