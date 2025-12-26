import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded message data for demonstration
    final List<Map<String, dynamic>> conversations = [
      {
        'id': '1',
        'name': 'John Doe',
        'lastMessage': 'Hey, are you available for the plumbing job?',
      },
      {
        'id': '2',
        'name': 'Jane Smith',
        'lastMessage': 'Thanks for the great work on the garden!',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: conversations.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final c = conversations[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                (c['name'] as String).isNotEmpty ? (c['name'] as String)[0] : '?',
              ),
            ),
            title: Text(c['name'] as String),
            subtitle: Text(c['lastMessage'] as String),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    peerName: c['name'] as String,
                    conversationId: c['id'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
