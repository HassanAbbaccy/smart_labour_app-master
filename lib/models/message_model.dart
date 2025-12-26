import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.sentAt,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['sentAt'];
    DateTime sent = DateTime.now();
    if (ts is Timestamp) sent = ts.toDate();
    return MessageModel(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      sentAt: sent,
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'senderId': senderId,
        'sentAt': FieldValue.serverTimestamp(),
      };
}
