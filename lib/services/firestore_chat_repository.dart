import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class FirestoreChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String gameId) {
    return _db.collection('games').doc(gameId).collection('messages');
  }

  /// Newest-first çekiyoruz (performans + pagination için daha iyi)
  Stream<List<ChatMessage>> watchMessages(String gameId, {int limit = 60}) {
    return _messagesRef(gameId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => ChatMessage.fromDoc(doc)).toList();
    });
  }

  /// createdAt serverTimestamp: cihaz saatinden bağımsız
  Future<void> sendMessage({
    required String gameId,
    required String userId,
    required String username,
    required String text,
  }) async {
    await _messagesRef(gameId).add({
      'userId': userId,
      'username': username,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final firestoreChatRepo = FirestoreChatRepository();
