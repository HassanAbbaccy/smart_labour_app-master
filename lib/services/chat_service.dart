import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of chats for current user
  Stream<List<ChatModel>> getChats() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ChatModel.fromDoc(doc)).toList();
        });
  }

  // Stream of messages for a specific chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => MessageModel.fromDoc(doc)).toList();
        });
  }

  // Send a message
  Future<void> sendMessage(String chatId, String text) async {
    final uid = currentUserId;
    if (uid == null) return;

    final messageData = {
      'senderId': uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // Add message to subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update chat metadata
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      // Logic for unread counts would go here (e.g., increment for other user)
    });
  }

  // Create or Get Chat ID
  Future<String> getorCreateChat(
    String otherUserId,
    Map<String, dynamic> otherUserData,
  ) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    // Check if chat exists (This is a simplified check, ideally specific ID logic)
    // For simplicity, we might query 'participants' combination
    // Or construct ID as 'uid1_uid2' (sorted)
    final ids = [uid, otherUserId]..sort();
    final chatId = ids.join('_');

    final doc = await _firestore.collection('chats').doc(chatId).get();

    if (!doc.exists) {
      // Fetch current user data to store basic info in chat desc
      // We'll trust the caller passes valid otherUserData

      await _firestore.collection('chats').doc(chatId).set({
        'participants': ids,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'participantData': {
          otherUserId: otherUserData,
          // We'd add current user data here too in a real app
        },
      });
    }

    return chatId;
  }
}
