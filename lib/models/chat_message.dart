import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  // Firestore'a yazmak için
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Firestore'dan okumak için
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      userId: map['userId'],
      username: map['username'],
      text: map['text'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
