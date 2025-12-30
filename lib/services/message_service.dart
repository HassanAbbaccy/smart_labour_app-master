import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getConversationId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String peerId,
    required String peerName,
  }) async {
    final chatId = getConversationId(currentUserId, peerId);
    final docRef = _firestore.collection('chats').doc(chatId);

    try {
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'participants': [currentUserId, peerId],
          'names': {currentUserId: 'You', peerId: peerName},
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': 0,
          'participantData': {
            currentUserId: {'name': 'User', 'role': 'Client'},
            peerId: {'name': peerName, 'role': 'Worker'},
          },
        });
      }
      return chatId;
    } catch (e) {
      debugPrint(
        '[MessageService] Firestore Error in getOrCreateConversation: $e',
      );
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> streamUserConversations(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return {
              'id': d.id,
              'participants': data['participants'],
              'names': data['names'] ?? {},
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageTime':
                  (data['lastMessageTime'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              'unreadCount': data['unreadCount'] ?? 0,
              'participantData': data['participantData'] ?? {},
            };
          }).toList(),
        );
  }

  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromDoc(d)).toList());
  }

  Future<void> sendMessage(
    String conversationId,
    MessageModel message,
    String receiverId,
  ) async {
    final ref = _firestore.collection('chats').doc(conversationId);

    // Add message
    await ref.collection('messages').add(message.toMap());

    // Update metadata and increment unread count for receiver
    await ref.update({
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    });
  }

  Future<void> markAsRead(String conversationId) async {
    await _firestore.collection('chats').doc(conversationId).update({
      'unreadCount': 0,
    });
  }

  // Temporary fix for dev_tools.dart
  Future<String> createConversation({
    required String name,
    String? initialMessage,
  }) async {
    final ref = await _firestore.collection('chats').add({
      'name': name,
      'lastMessage': initialMessage ?? '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [],
    });
    return ref.id;
  }
}
