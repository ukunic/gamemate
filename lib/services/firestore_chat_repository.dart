import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class FirestoreChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String gameId) {
    return _db.collection('games').doc(gameId).collection('messages');
  }

  Stream<List<ChatMessage>> watchMessages(String gameId) {
    return _messagesRef(gameId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
  }

  Future<void> sendMessage({
    required String gameId,
    required ChatMessage message,
  }) async {
    await _messagesRef(gameId).add(message.toMap());
  }
}
