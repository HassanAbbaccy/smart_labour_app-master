import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/notification_model.dart';


class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<JobModel>> streamJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'OPEN')
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => JobModel.fromDoc(d)).toList();
          list.sort((a, b) {
            final aTime = a.createdAt ?? DateTime.now();
            final bTime = b.createdAt ?? DateTime.now();
            return bTime.compareTo(aTime);
          });
          return list;
        });
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
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptHiredJob(String jobId, String clientId, String workerName, String jobTitle) async {
    // 1. Update Job Status
    await _firestore.collection('jobs').doc(jobId).update({
      'status': 'IN PROGRESS',
      'startedAt': FieldValue.serverTimestamp(),
    });

    // 2. Notify Client that work has started
    await createNotification(NotificationModel(
      id: '',
      receiverId: clientId,
      title: 'Job Started',
      body: '$workerName has accepted and started the job: $jobTitle',
      type: 'status_update',
      timestamp: DateTime.now(),
      data: {'jobId': jobId},
    ));
  }

  Future<void> declineJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'status': 'DECLINED',
    });
  }

  Future<void> completeJob(String jobId, String workerId, String clientId, double pay, int rating, String reviewText) async {
    final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) return;
    
    final jobData = jobDoc.data() as Map<String, dynamic>;
    final jobTitle = jobData['title'] ?? 'Job';

    // Update job status
    Map<String, dynamic> jobUpdates = {
      'status': 'COMPLETED',
      'completedAt': FieldValue.serverTimestamp(),
    };

    // Release Escrow if payment was held
    bool releaseEscrow = false;
    if (jobData['paymentStatus'] == 'IN_ESCROW') {
      releaseEscrow = true;
      jobUpdates['paymentStatus'] = 'RELEASED';
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

    // Obtain worker to calculate new average rating
    final workerRef = _firestore.collection('users').doc(workerId);
    final workerDoc = await workerRef.get();
    
    if (workerDoc.exists) {
      final wData = workerDoc.data()!;
      int currentTotalReviews = wData['totalReviews'] ?? 0;
      double currentRating = (wData['rating'] ?? 4.8).toDouble();
      
      int newTotalReviews = currentTotalReviews + 1;
      double newRating = ((currentRating * currentTotalReviews) + rating) / newTotalReviews;
      
      workerUpdates['rating'] = newRating;
      workerUpdates['totalReviews'] = newTotalReviews;
    }

    await workerRef.update(workerUpdates);

    // Save the review record
    await _firestore.collection('reviews').add({
      'jobId': jobId,
      'workerId': workerId,
      'clientId': clientId,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 4. Notify Worker of payment release and review
    await createNotification(NotificationModel(
      id: '',
      receiverId: workerId,
      title: 'Payment Released',
      body: 'Your payment of Rs. ${pay.toInt()} for "$jobTitle" has been released to your wallet!',
      type: 'status_update',
      timestamp: DateTime.now(),
      data: {'jobId': jobId},
    ));
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
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => ApplicationModel.fromDoc(d)).toList();
          list.sort((a, b) {
            final aTime = a.createdAt ?? DateTime.now();
            final bTime = b.createdAt ?? DateTime.now();
            return bTime.compareTo(aTime);
          });
          return list;
        });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> notifyWorkerHired(String jobId, String workerId, String clientName, String jobTitle) async {
    await createNotification(NotificationModel(
      id: '',
      receiverId: workerId,
      title: 'You have been Hired!',
      body: 'Congratulations! $clientName has hired you for the job: $jobTitle',
      type: 'hiring',
      timestamp: DateTime.now(),
      data: {'jobId': jobId},
    ));
  }
}
