class Message {
  final String id;
  final String chatId; // eventId or DM id
  final String senderId;
  final String content;
  final String? attachmentUrl;
  final DateTime createdAt;
  
  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.attachmentUrl,
    required this.createdAt,
  });
  
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
