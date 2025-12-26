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
}
