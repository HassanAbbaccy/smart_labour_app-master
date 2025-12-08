import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final convos = [
      {'name': 'ABC Corp', 'last': 'Thanks for the update'},
      {'name': 'Client Jane', 'last': 'When can you start?'},
      {'name': 'Booking Bot', 'last': 'Your booking is confirmed'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final c = convos[index];
          return ListTile(
            leading: CircleAvatar(child: Text(c['name']![0])),
            title: Text(c['name']!),
            subtitle: Text(c['last']!),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Open chat with ${c['name']} (demo)')),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: convos.length,
      ),
    );
  }
}
