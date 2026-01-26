import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id; // Firestore doc id
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  /// Firestore'a yazmak için
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'username': username,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  /// Firestore'dan okumak için (doc id ile)
  factory ChatMessage.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    final ts = data['createdAt'] as Timestamp?;

    return ChatMessage(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      username: (data['username'] ?? 'Unknown') as String,
      text: (data['text'] ?? '') as String,
      createdAt: ts?.toDate() ?? DateTime.now(),
    );
  }
}
