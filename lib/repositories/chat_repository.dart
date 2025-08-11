import '../models/message.dart';
import '../services/i_chat_service.dart';

class ChatRepository {
  final IChatService _chatService;
  
  ChatRepository(this._chatService);
  
  Future<List<Message>> getMessages(String chatId, {int limit = 20, int offset = 0}) {
    return _chatService.getMessages(chatId, limit: limit, offset: offset);
  }
  
  Future<Message> sendMessage(Message message) {
    return _chatService.sendMessage(message);
  }
  
  Future<void> deleteMessage(String messageId) {
    return _chatService.deleteMessage(messageId);
  }
  
  Future<List<String>> getChatIds(String userId) {
    return _chatService.getChatIds(userId);
  }
  
  Stream<Message> onNewMessage(String chatId) {
    return _chatService.onNewMessage(chatId);
  }
}
