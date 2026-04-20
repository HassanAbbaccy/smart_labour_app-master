import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';
import 'job_applicants_screen.dart';
import 'package:intl/intl.dart';
import '../services/localization_service.dart';

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

  Future<void> _handleAccept() async {
    final j = widget.job;
    if (j == null) return;
    
    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() => _isApplying = true); // Repurpose isApplying for loading state
    try {
      await JobService().acceptHiredJob(
        j.id, 
        j.clientId ?? '', 
        user.fullName, 
        j.title
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job Accepted! You can now start working.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Refresh or go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
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

  Future<void> _showRatingDialog(JobModel j, double payAmount) async {
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
                        Navigator.pop(context); // Go back to feed
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
    final j = widget.job;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: Text(j?.title ?? tr('job_details')),
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
                          if (j.status?.toUpperCase() == 'COMPLETED' && j.startedAt != null && j.completedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF009688)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Time Taken: ${_formatDuration(j.completedAt!.difference(j.startedAt!))}',
                                    style: const TextStyle(
                                      color: Color(0xFF009688),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          if (j.scheduledAt != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 18, color: Color(0xFF009688)),
                                const SizedBox(width: 8),
                                Text(
                                  '${tr('schedule_job')}: ${DateFormat('MMM dd, hh:mm a').format(j.scheduledAt!)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00BCD4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Description Section
                    Text(
                      tr('description'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    
                    // Owner vs Worker Button
                    SizedBox(
                      width: double.infinity,
                      child: _buildActionButton(j),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildActionButton(JobModel j) {
    final currentUser = AuthService().currentUser;
    final isClient = j.clientId == currentUser?.uid;
    final isWorker = j.workerId == currentUser?.uid;
    
    if (isClient) {
      if (j.status == 'IN PROGRESS') {
        return ElevatedButton.icon(
          onPressed: () {
            // Robust Whole-Number Parsing
            final rawVal = j.pay;
            final noPrefix = rawVal.toLowerCase().replaceAll('rs.', '').replaceAll('rs', '').trim();
            final beforeDot = noPrefix.contains('.') ? noPrefix.split('.')[0] : noPrefix;
            final cleanAmount = beforeDot.replaceAll(RegExp(r'[^0-9]'), '');
            final payAmount = double.tryParse(cleanAmount) ?? 0.0;
            
            _showRatingDialog(j, payAmount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.check_circle),
          label: Text(
            tr('mark_completed'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }
      
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobApplicantsScreen(job: j),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF009688),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.people_outline),
        label: Text(
          'View Applicants (${j.workersOffered ?? 0})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    // If I am the hired worker
    if (isWorker) {
      if (j.status == 'HIRED') {
        return ElevatedButton.icon(
          onPressed: _isApplying ? null : _handleAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009688),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: _isApplying
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check_circle_outline),
          label: Text(
            _isApplying ? 'Starting...' : 'Accept & Start Job',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }
      
      if (j.status == 'IN PROGRESS') {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF009688)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: Color(0xFF009688)),
              SizedBox(width: 8),
              Text(
                'Job is In Progress',
                style: TextStyle(color: Color(0xFF009688), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }
    }

    // Default: Apply for Job
    return ElevatedButton.icon(
      onPressed: (j.status == 'HIRED' || j.status == 'IN PROGRESS')
          ? null
          : (_isApplying ? null : _handleApply),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A1C18),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: _isApplying
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.send),
      label: Text(
        j.status == 'HIRED' || j.status == 'IN PROGRESS' 
            ? 'Job Closed' 
            : (_isApplying ? 'Applying...' : 'Apply for Job'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
