import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String location;
  final String pay;
  final String description;
  final DateTime? createdAt;
  final String? status; // 'IN PROGRESS', 'REQUESTED', 'SCHEDULED'
  final String? workerName;
  final String? workerAvatarUrl;
  final int? workersOffered;
  final String? jobIconUrl;
  final bool isRangePrice;
  final String? maxPrice;
  final String? workerId;
  final String? clientId;

  final String? paymentStatus; // 'PENDING', 'PAID'
  final String? paymentMethod; // 'EasyPaisa', 'JazzCash', 'Bank'
  final DateTime? startedAt;
  final DateTime? completedAt;

  JobModel({
    required this.id,
    required this.title,
    required this.location,
    required this.pay,
    required this.description,
    this.createdAt,
    this.status,
    this.workerName,
    this.workerAvatarUrl,
    this.workersOffered,
    this.jobIconUrl,
    this.isRangePrice = false,
    this.maxPrice,
    this.workerId,
    this.clientId,
    this.paymentStatus = 'PENDING',
    this.paymentMethod,
    this.startedAt,
    this.completedAt,
  });

  factory JobModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'];
    final tsStarted = data['startedAt'];
    final tsCompleted = data['completedAt'];

    DateTime? created;
    DateTime? started;
    DateTime? completed;

    if (ts is Timestamp) created = ts.toDate();
    if (tsStarted is Timestamp) started = tsStarted.toDate();
    if (tsCompleted is Timestamp) completed = tsCompleted.toDate();

    return JobModel(
      id: doc.id,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      pay: data['pay'] ?? '',
      description: data['description'] ?? '',
      createdAt: created,
      status: data['status'],
      workerName: data['workerName'],
      workerAvatarUrl: data['workerAvatarUrl'],
      workersOffered: data['workersOffered'],
      jobIconUrl: data['jobIconUrl'],
      isRangePrice: data['isRangePrice'] ?? false,
      maxPrice: data['maxPrice'],
      workerId: data['workerId'],
      clientId: data['clientId'],
      paymentStatus: data['paymentStatus'] ?? 'PENDING',
      paymentMethod: data['paymentMethod'],
      startedAt: started,
      completedAt: completed,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'location': location,
    'pay': pay,
    'description': description,
    'createdAt': FieldValue.serverTimestamp(),
    'status': status,
    'workerName': workerName,
    'workerAvatarUrl': workerAvatarUrl,
    'workersOffered': workersOffered,
    'jobIconUrl': jobIconUrl,
    'isRangePrice': isRangePrice,
    'maxPrice': maxPrice,
    'workerId': workerId,
    'clientId': clientId,
    'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod,
    'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
  };
}

class ApplicationModel {
  final String id;
  final String jobId;
  final String workerId;
  final String workerName;
  final String workerProfession;
  final String workerAvatarUrl;
  final double workerRating;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime? createdAt;
  final String? coverLetter;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.workerName,
    required this.workerProfession,
    required this.workerAvatarUrl,
    required this.workerRating,
    this.status = 'pending',
    this.createdAt,
    this.coverLetter,
  });

  factory ApplicationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();

    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      workerId: data['workerId'] ?? '',
      workerName: data['workerName'] ?? '',
      workerProfession: data['workerProfession'] ?? '',
      workerAvatarUrl: data['workerAvatarUrl'] ?? '',
      workerRating: (data['workerRating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: created,
      coverLetter: data['coverLetter'],
    );
  }

  Map<String, dynamic> toMap() => {
    'jobId': jobId,
    'workerId': workerId,
    'workerName': workerName,
    'workerProfession': workerProfession,
    'workerAvatarUrl': workerAvatarUrl,
    'workerRating': workerRating,
    'status': status,
    'createdAt': FieldValue.serverTimestamp(),
    'coverLetter': coverLetter,
  };
}
