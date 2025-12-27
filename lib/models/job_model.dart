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
  });

  factory JobModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();
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
  };
}
