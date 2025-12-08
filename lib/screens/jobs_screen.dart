import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = [
      {'title': 'House Cleaning', 'location': 'Downtown', 'pay': '\$45/hr'},
      {'title': 'Plumbing Repair', 'location': 'Midtown', 'pay': '\$60/hr'},
      {'title': 'Tutoring Service', 'location': 'Uptown', 'pay': '\$50/hr'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Card(
            child: ListTile(
              title: Text(job['title']!),
              subtitle: Text(job['location']! + ' · ' + job['pay']!),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Applied (demo)')),
                  );
                },
                child: const Text('Apply'),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: jobs.length,
      ),
    );
  }
}
