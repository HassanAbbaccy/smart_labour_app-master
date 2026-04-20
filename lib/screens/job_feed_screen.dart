import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/job_service.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/empty_state_widget.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _applyToJob(JobModel job, UserModel worker) async {
    // Show a quick dialog for cover letter (optional)
    final coverController = TextEditingController();
    bool confirm =
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Apply for ${job.title}'),
            content: TextField(
              controller: coverController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Briefly explain why you are a good fit (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Application'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    // Check if genuinely applied already
    final existingRef = await _firestore
        .collection('applications')
        .where('jobId', isEqualTo: job.id)
        .where('workerId', isEqualTo: worker.uid)
        .get();

    if (existingRef.docs.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already applied!')),
        );
      }
      return;
    }

    final application = ApplicationModel(
      id: '',
      jobId: job.id,
      workerId: worker.uid,
      workerName: worker.fullName,
      workerProfession: worker.profession,
      workerAvatarUrl: worker.avatarUrl ?? '',
      workerRating: worker.rating,
      coverLetter: coverController.text.trim(),
    );

    try {
      await JobService().applyForJob(application, job.clientId ?? '', job.title);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to apply. $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final worker = AuthService().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: const Text('Job Feed'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1C18),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('jobs')
            .where('status', isEqualTo: 'OPEN')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildFeedShimmer();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const PremiumEmptyState(
              title: 'No Jobs Available',
              subtitle:
                  'Check back later! New opportunities appear here as soon as clients post them.',
              icon: Icons.work_off_outlined,
            );
          }

          final jobs = snapshot.data!.docs
              .map((d) => JobModel.fromDoc(d))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'OPEN',
                            style: TextStyle(
                              color: Color(0xFF009688),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          job.pay,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF009688),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (worker != null) {
                              _applyToJob(job, worker);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009688),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
          },
          );
        },
      ),
    );
  }

  Widget _buildFeedShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => const ShimmerLoading(
        isLoading: true,
        child: ShimmerPlaceholder(height: 120, borderRadius: 16),
      ),
    );
  }
}
