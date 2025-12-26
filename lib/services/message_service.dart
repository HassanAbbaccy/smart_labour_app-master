import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a conversation and return its id.
  Future<String> createConversation({
    required String name,
    String? initialMessage,
  }) async {
    final ref = await _firestore.collection('conversations').add({
      'name': name,
      'lastMessage': initialMessage ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Ensure a conversation exists with the provided id (no-op if exists).
  Future<void> ensureConversation(String id, {required String name}) async {
    final docRef = _firestore.collection('conversations').doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'name': name,
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<Map<String, dynamic>>> streamConversations() {
    return _firestore
        .collection('conversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return {
              'id': d.id,
              'name': data['name'] ?? '',
              'lastMessage': data['lastMessage'] ?? '',
            };
          }).toList(),
        );
  }

  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromDoc(d)).toList());
  }

  Future<void> sendMessage(String conversationId, MessageModel message) async {
    final ref = _firestore.collection('conversations').doc(conversationId);
    await ref.collection('messages').add(message.toMap());
    await ref.update({
      'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
