import '../models/game.dart';

class ChatRepository {
  static final Map<String, List<ChatMessage>> _store = {};

  static List<ChatMessage> messagesFor(Game game) {
    return _store.putIfAbsent(game.id, () => []);
  }

  static void addMessage(Game game, ChatMessage message) {
    messagesFor(game).add(message);
  }
}

class ChatMessage {
  final String user;
  final String text;
  final String time;

  const ChatMessage({
    required this.user,
    required this.text,
    required this.time,
  });
}
