import '../models/message.dart';

abstract class IChatService {
  Future<List<Message>> getMessages(String chatId, {int limit = 20, int offset = 0});
  Future<Message> sendMessage(Message message);
  Future<void> deleteMessage(String messageId);
  Future<List<String>> getChatIds(String userId);
  Stream<Message> onNewMessage(String chatId);
}
