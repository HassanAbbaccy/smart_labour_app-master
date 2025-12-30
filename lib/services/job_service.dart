import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<JobModel>> streamJobs() {
    return _firestore
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => JobModel.fromDoc(d)).toList());
  }

  Future<JobModel?> getJob(String id) async {
    final doc = await _firestore.collection('jobs').doc(id).get();
    if (!doc.exists) return null;
    return JobModel.fromDoc(doc);
  }

  Future<void> createJob(JobModel job) async {
    await _firestore.collection('jobs').add(job.toMap());
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await _firestore.collection('jobs').doc(jobId).update({'status': status});
  }

  Future<void> acceptJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'status': 'IN PROGRESS',
    });
  }

  Future<void> declineJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'status': 'DECLINED',
    });
  }

  Future<void> completeJob(String jobId, String workerId, double pay) async {
    // Update job status
    await _firestore.collection('jobs').doc(jobId).update({
      'status': 'COMPLETED',
    });

    // Update worker stats
    final workerRef = _firestore.collection('users').doc(workerId);
    await workerRef.update({
      'completedJobs': FieldValue.increment(1),
      'monthlyEarnings': FieldValue.increment(pay),
    });
  }
}
