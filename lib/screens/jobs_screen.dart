import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';
import 'job_applicants_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().firebaseUser?.uid;
    final userRole = AuthService().currentUser?.role;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Jobs',
          style: TextStyle(
            color: Color(0xFF003829),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF00BFA5),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF00BFA5),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              labelPadding: const EdgeInsets.only(right: 24, bottom: 8),
              indicatorPadding: const EdgeInsets.only(right: 24),
              tabs: const [Text('Active'), Text('History'), Text('Drafts')],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobStream(uid, userRole, [
            'OPEN',
            'IN PROGRESS',
            'REQUESTED',
            'SCHEDULED',
          ]),
          _buildJobStream(uid, userRole, ['COMPLETED', 'CANCELLED']),
          const Center(child: Text('Drafts')),
        ],
      ),
    );
  }

  Widget _buildJobStream(String uid, String? role, List<String> statuses) {
    Query query = FirebaseFirestore.instance.collection('jobs');

    if (role == 'Worker') {
      query = query.where('workerId', isEqualTo: uid);
    } else {
      query = query.where('clientId', isEqualTo: uid);
    }

    query = query.where('status', whereIn: statuses);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No jobs found.'));
        }

        final jobs = snapshot.data!.docs
            .map((doc) => JobModel.fromDoc(doc))
            .toList();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return GestureDetector(
              onTap: () {
                if (role != 'Worker' && job.status == 'OPEN') {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => JobApplicantsScreen(job: job)));
                }
              },
              child: _JobCard(job: job, isWorker: role == 'Worker'),
            );
          },
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final bool isWorker;

  const _JobCard({required this.job, required this.isWorker});

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text(
          'Are you sure you want to cancel this service request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('jobs')
                  .doc(job.id)
                  .update({'status': 'CANCELLED'});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRatingDialog(BuildContext context, JobModel j, double payAmount) async {
    int rating = 0;
    final reviewController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Rate Worker', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please rate the worker\'s performance. This is required to complete the job.'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a quick review... (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (rating == 0 || isSubmitting) ? null : () async {
                    setDialogState(() => isSubmitting = true);
                    final currentUser = AuthService().currentUser!;
                    try {
                      await JobService().completeJob(
                        j.id, 
                        j.workerId ?? '', 
                        currentUser.uid,
                        payAmount,
                        rating,
                        reviewController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Job Completed & Reviewed!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                        setDialogState(() => isSubmitting = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit & Complete'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = job.status?.toUpperCase() ?? '';
    final isOpen = status == 'OPEN';
    final isRequested = status == 'REQUESTED';
    final isInProgress = status == 'IN PROGRESS';

    Color statusColor = const Color(0xFFE0F2F1);
    Color statusTextColor = const Color(0xFF009688);

    if (isOpen) {
       statusColor = const Color(0xFFE3F2FD);
       statusTextColor = const Color(0xFF1976D2);
    } else if (isRequested) {
      statusColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFEF6C00);
    } else if (isInProgress) {
      statusColor = const Color(0xFFE0F7FA);
      statusTextColor = const Color(0xFF00BCD4);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.location,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (job.status?.toUpperCase() == 'COMPLETED' &&
              job.startedAt != null &&
              job.completedAt != null) ...[
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  'Time Taken: ${_formatDuration(job.completedAt!.difference(job.startedAt!))}',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${job.pay}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (!isWorker && isOpen)
                const Text(
                  'Tap to View Applicants',
                  style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              if (isWorker && isRequested)
                ElevatedButton(
                  onPressed: () => JobService().acceptJob(job.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              if (!isWorker && isInProgress)
                ElevatedButton(
                  onPressed: () {
                    // Robust Whole-Number Parsing
                    final rawVal = job.pay;
                    final noPrefix = rawVal.toLowerCase().replaceAll('rs.', '').replaceAll('rs', '').trim();
                    final beforeDot = noPrefix.contains('.') ? noPrefix.split('.')[0] : noPrefix;
                    final cleanAmount = beforeDot.replaceAll(RegExp(r'[^0-9]'), '');
                    final payAmount = double.tryParse(cleanAmount) ?? 0.0;
                    _showRatingDialog(context, job, payAmount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark Completed'),
                ),
              if (!isWorker && isRequested)
                OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Cancel Request'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }
}
