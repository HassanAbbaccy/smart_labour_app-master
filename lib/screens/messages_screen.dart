import 'package:flutter/material.dart';
import 'package:untitled4/models/chat_model.dart';
import 'package:untitled4/services/chat_service.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatService _chatService = ChatService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C18),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search chats...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chat List
            Expanded(
              child: StreamBuilder<List<ChatModel>>(
                stream: _chatService.getChats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter logic
                  final chats = snapshot.data!.where((chat) {
                    if (_searchQuery.isEmpty) return true;
                    // Find peer name
                    String name = 'User';
                    final currentUserId = AuthService().currentUser?.uid;
                    chat.participantData.forEach((key, value) {
                      if (key != currentUserId) {
                        final map = value as Map<String, dynamic>;
                        name =
                            (map['name'] as String?) ??
                            (map['firstName'] as String?) ??
                            'User';
                      }
                    });
                    return name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                  }).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80), // for nav bar
                    itemCount: chats.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 84,
                      endIndent: 24,
                      color: Color(0xFFEEEEEE),
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return _buildChatItem(chat);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    // Identify Peer
    final currentUserId = AuthService().currentUser?.uid;
    // Basic logic: find participant that is NOT me
    // We assume 'participantData' has info for the OTHER user
    // or we fetch it. For now, let's look at the Map we defined in ChatModel.

    // Fallback data
    String name = 'User';
    String role = 'Worker';
    String? avatar;
    bool isOnline = chat.unreadCount > 0; // Mock: Online if unread messages

    // In a real scenario, we'd pick the keys from `chat.participantData`
    // that don't vary.
    chat.participantData.forEach((key, value) {
      if (key != currentUserId) {
        final map = value as Map<String, dynamic>;
        name = map['name'] ?? map['firstName'] ?? 'User';
        role = map['role'] ?? map['profession'] ?? '';
        avatar = map['avatar'];
      }
    });

    final timeStr = _formatTime(chat.lastMessageTime);

    return InkWell(
      onTap: () {
        // Navigate to Chat Detail (We will need to implement or link ChatScreen properly)
        // For now, preserving existing placeholder link or creating new
        // Navigator.push(...)
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: avatar != null
                      ? NetworkImage(avatar!)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: avatar == null
                      ? Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853), // Online Green
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C18),
                        ),
                      ),
                      if (role.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.unreadCount > 0
                              ? const Color(0xFF00BCD4)
                              : Colors.grey[500],
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.unreadCount > 0
                                ? const Color(0xFF1A1C18)
                                : Colors.grey[600],
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00BCD4),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0 && now.day == time.day) {
      return DateFormat('h:mm a').format(time);
    } else if (diff.inDays == 0 || (diff.inDays == 1 && now.day != time.day)) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('E').format(time); // Mon, Tue
    } else {
      return DateFormat('MMM d').format(time); // Oct 24
    }
  }
}
