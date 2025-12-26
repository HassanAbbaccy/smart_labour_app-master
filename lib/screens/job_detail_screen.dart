import 'package:flutter/material.dart';
import '../models/job_model.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel? job;
  const JobDetailScreen({super.key, this.job});

  @override
  Widget build(BuildContext context) {
    final j = job;
    return Scaffold(
      appBar: AppBar(title: Text(j?.title ?? 'Job Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: j == null
            ? const Center(child: Text('Job not found'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    j.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(j.location),
                      const Spacer(),
                      Text(j.pay, style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Job Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(j.description.isNotEmpty ? j.description : 'No description provided.'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied (demo)')));
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Apply for Job'),
                  ),
                ],
              ),
      ),
    );
  }
}
