import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/notification_model.dart';


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
    final jobDoc = await _firestore.collection('jobs').doc(jobId).get();

    // Update job status
    Map<String, dynamic> jobUpdates = {'status': 'COMPLETED'};

    // Release Escrow if payment was held
    bool releaseEscrow = false;
    if (jobDoc.exists) {
      final jobData = jobDoc.data() as Map<String, dynamic>;
      if (jobData['paymentStatus'] == 'IN_ESCROW') {
        releaseEscrow = true;
        jobUpdates['paymentStatus'] = 'RELEASED';
      }
    }

    await _firestore.collection('jobs').doc(jobId).update(jobUpdates);

    // Update worker stats
    Map<String, dynamic> workerUpdates = {
      'completedJobs': FieldValue.increment(1),
      'monthlyEarnings': FieldValue.increment(pay),
    };

    if (releaseEscrow) {
      workerUpdates['escrowBalance'] = FieldValue.increment(-pay);
      workerUpdates['walletBalance'] = FieldValue.increment(pay);
    }

    final workerRef = _firestore.collection('users').doc(workerId);
    await workerRef.update(workerUpdates);
  }

  Future<void> applyForJob(ApplicationModel app, String clientId, String jobTitle) async {
    // 1. Save to a root 'applications' collection
    await _firestore.collection('applications').add(app.toMap());

    // 2. Increment workersOffered in the job document
    await _firestore.collection('jobs').doc(app.jobId).update({
      'workersOffered': FieldValue.increment(1),
    });

    // 3. Create a notification for the client
    await createNotification(NotificationModel(
      id: '', // Firestore will generate
      receiverId: clientId,
      title: 'New Application',
      body: '${app.workerName} applied for your job: $jobTitle',
      type: 'application',
      timestamp: DateTime.now(),
      data: {'jobId': app.jobId},
    ));
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore.collection('notifications').add(notification.toMap());
  }

  Stream<List<ApplicationModel>> streamJobApplications(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ApplicationModel.fromDoc(d)).toList());
  }
}
