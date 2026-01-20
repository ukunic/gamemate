import '../models/chat_message.dart';

class ChatRepository {
  final Map<String, List<ChatMessage>> _store = {};

  List<ChatMessage> messagesForRoom(String roomId) {
    return _store.putIfAbsent(roomId, () => []);
  }

  void addMessage(String roomId, ChatMessage message) {
    messagesForRoom(roomId).add(message);
  }
}
