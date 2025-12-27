import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['timestamp'] ?? data['sentAt'];
    DateTime time = DateTime.now();
    if (ts is Timestamp) time = ts.toDate();
    return MessageModel(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: time,
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'senderId': senderId,
    'timestamp': FieldValue.serverTimestamp(),
    'isRead': isRead,
  };
}
