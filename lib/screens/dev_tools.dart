import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:untitled4/models/job_model.dart';
import 'package:untitled4/models/message_model.dart';
import 'package:untitled4/services/job_service.dart';
import 'package:untitled4/services/message_service.dart';

class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  Future<void> _seedSampleData(BuildContext context) async {
    final jobService = JobService();
    final msgService = MessageService();

    final jobs = [
      JobModel(id: '', title: 'House Cleaning', location: 'Downtown', pay: '\$45/hr', description: 'Clean a 2 bedroom apartment.'),
      JobModel(id: '', title: 'Plumbing Repair', location: 'Midtown', pay: '\$60/hr', description: 'Fix leaking sink'),
      JobModel(id: '', title: 'Tutoring Service', location: 'Uptown', pay: '\$50/hr', description: 'Math tutoring for high school student'),
    ];

    for (final j in jobs) {
      await jobService.createJob(j);
    }

    // seed conversations
    final convId = await msgService.createConversation(name: 'Demo Client', initialMessage: 'Welcome');
    await msgService.sendMessage(convId, MessageModel(id: '', text: 'Hello from demo client', senderId: 'client', sentAt: DateTime.now()));

    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded demo jobs and conversation')));
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(body: Center(child: Text('Dev tools are available only in debug mode')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _seedSampleData(context),
              child: const Text('Seed sample jobs & conversations'),
            ),
            const SizedBox(height: 12),
            const Text('Use this screen to seed demo data into Firestore (debug only).'),
          ],
        ),
      ),
    );
  }
}
