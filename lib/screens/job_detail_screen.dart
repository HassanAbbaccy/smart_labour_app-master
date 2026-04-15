import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel? job;
  const JobDetailScreen({super.key, this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isApplying = false;

  Future<void> _handleApply() async {
    final j = widget.job;
    if (j == null) return;

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to apply')),
      );
      return;
    }

    if (user.role != 'Worker') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only workers can apply for jobs')),
      );
      return;
    }

    setState(() => _isApplying = true);

    try {
      final application = ApplicationModel(
        id: '', // Firestore will generate
        jobId: j.id,
        workerId: user.uid,
        workerName: user.fullName,
        workerProfession: user.profession,
        workerAvatarUrl: user.avatarUrl ?? 'https://i.pravatar.cc/150?u=${user.uid}',
        workerRating: user.rating,
        status: 'pending',
      );

      await JobService().applyForJob(application, j.clientId ?? '', j.title);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying for job: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Application Sent!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your interest in "${widget.job?.title}" has been shared with the client. You will be notified if they accept.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to feed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back to Job Feed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: Text(j?.title ?? 'Job Detail'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: j == null
          ? const Center(child: Text('Job not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Job Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          j.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1C18),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Color(0xFF009688)),
                            const SizedBox(width: 4),
                            Text(j.location, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                            const Spacer(),
                            Text(
                              j.pay,
                              style: const TextStyle(
                                color: Color(0xFF009688),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Description Section
                  const Text(
                    'Job Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      j.description.isNotEmpty
                          ? j.description
                          : 'No description provided.',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isApplying ? null : _handleApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1C18),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isApplying 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          ) 
                        : const Icon(Icons.send),
                      label: Text(
                        _isApplying ? 'Applying...' : 'Apply for Job',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
