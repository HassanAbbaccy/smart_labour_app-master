import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      JobModel(
        id: '',
        title: 'House Cleaning',
        location: 'Downtown',
        pay: '\$45/hr',
        description: 'Clean a 2 bedroom apartment.',
      ),
      JobModel(
        id: '',
        title: 'Plumbing Repair',
        location: 'Midtown',
        pay: '\$60/hr',
        description: 'Fix leaking sink',
      ),
      JobModel(
        id: '',
        title: 'Tutoring Service',
        location: 'Uptown',
        pay: '\$50/hr',
        description: 'Math tutoring for high school student',
      ),
    ];

    for (final j in jobs) {
      await jobService.createJob(j);
    }

    // seed conversations
    final convId = await msgService.createConversation(
      name: 'Demo Client',
      initialMessage: 'Welcome',
    );
    await msgService.sendMessage(
      convId,
      MessageModel(
        id: '',
        text: 'Hello from demo client',
        senderId: 'client',
        timestamp: DateTime.now(),
      ),
      'worker', // receiverId for demo
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeded demo jobs and conversation')),
      );
    }
  }

  Future<void> _testFirestoreAccess(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final testDoc = firestore.collection('chats').doc('test_permission_system');

    try {
      // 1. Try to Write
      await testDoc.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': ['system_test'],
      });

      // 2. Try to Read
      final doc = await testDoc.get();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Firestore Success'),
            content: Text(
              'Successfully wrote and read from "chats" collection.\n\nData: ${doc.data()}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      // Cleanup
      await testDoc.delete();
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Firestore Permission Denied'),
            content: Text(
              'Error: $e\n\nPlease check your Firestore Rules in the Firebase Console.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Dev tools are available only in debug mode')),
      );
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
            ElevatedButton(
              onPressed: () => _testFirestoreAccess(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                '⚠️ Test Firestore Permission (chats collection)',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Use this screen to seed demo data or test Firestore permissions into Firestore (debug only).',
            ),
          ],
        ),
      ),
    );
  }
}
