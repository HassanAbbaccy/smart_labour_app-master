import 'package:flutter/material.dart';
import 'package:untitled4/services/message_service.dart';
import 'package:untitled4/services/auth_service.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String peerName;
  final String? conversationId;
  const ChatScreen({super.key, required this.peerName, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final MessageService _service = MessageService();

  Future<void> _send(String conversationId) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final userId = AuthService().firebaseUser?.uid ?? 'anon';
    final msg = MessageModel(id: '', text: text, senderId: userId, sentAt: DateTime.now());
    await _service.sendMessage(conversationId, msg);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final convId = widget.conversationId;
    return Scaffold(
      appBar: AppBar(title: Text(widget.peerName)),
      body: convId == null
          ? const Center(child: Text('Conversation not available'))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<MessageModel>>(
                    stream: _service.streamMessages(convId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      final messages = snapshot.data ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final m = messages[index];
                          final fromMe = m.senderId == AuthService().firebaseUser?.uid;
                          final align = fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                          final color = fromMe ? Colors.blue : Colors.grey.shade200;
                          final textColor = fromMe ? Colors.white : Colors.black87;
                          return Column(
                            crossAxisAlignment: align,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(m.text, style: TextStyle(color: textColor)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(hintText: 'Type a message'),
                            onSubmitted: (_) => _send(convId),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _send(convId),
                          child: const Icon(Icons.send),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
