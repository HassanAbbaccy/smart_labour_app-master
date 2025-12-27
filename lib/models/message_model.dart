import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts =
        data['sentAt'] ??
        data['timestamp']; // Support both for safety during migration
    DateTime sent = DateTime.now();
    if (ts is Timestamp) sent = ts.toDate();
    return MessageModel(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      sentAt: sent,
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'senderId': senderId,
    'sentAt': FieldValue.serverTimestamp(),
    'isRead': isRead,
  };
}
