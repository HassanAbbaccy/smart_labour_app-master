import 'package:flutter/material.dart';
import 'package:untitled4/services/message_service.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageService _messageService = MessageService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUser?.uid;

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search chats...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF009688)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chat List
            Expanded(
              child: currentUserId == null
                  ? const Center(child: Text('Please login to see messages'))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _messageService.streamUserConversations(
                        currentUserId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Error loading chats: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final conversations = snapshot.data ?? [];
                        final filteredConversations = conversations.where((
                          conv,
                        ) {
                          if (_searchQuery.isEmpty) return true;
                          final names =
                              conv['names'] as Map<String, dynamic>? ?? {};
                          return names.values.any(
                            (name) => name.toString().toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          );
                        }).toList();

                        if (filteredConversations.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: filteredConversations.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildConversationItem(
                              filteredConversations[index],
                              currentUserId,
                            );
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Color(0xFF009688),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your messages will appear here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(
    Map<String, dynamic> conv,
    String currentUserId,
  ) {
    // Determine peer name
    final names = conv['names'] as Map<String, dynamic>? ?? {};
    String peerName = 'User';
    names.forEach((uid, name) {
      if (uid != currentUserId) peerName = name;
    });

    final lastMessage = conv['lastMessage'] ?? '';
    final lastTime = conv['lastMessageTime'] as DateTime;
    final unreadCount = conv['unreadCount'] ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatScreen(peerName: peerName, conversationId: conv['id']),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF009688).withValues(alpha: 0.1),
              child: Text(
                peerName.isNotEmpty ? peerName[0] : '?',
                style: const TextStyle(
                  color: Color(0xFF009688),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        peerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(lastTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage.isEmpty
                              ? 'Start a conversation'
                              : lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: lastMessage.isEmpty
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF009688),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
    } else if (diff.inDays < 7) {
      return DateFormat('E').format(time);
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
