import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reportedById;
  final String reportedId; // UID of user or ID of job
  final String type; // 'user' or 'job'
  final String reason;
  final String details;
  final String status; // 'pending', 'resolved', 'dismissed'
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reportedById,
    required this.reportedId,
    required this.type,
    required this.reason,
    required this.details,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportedById': reportedById,
      'reportedId': reportedId,
      'type': type,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      reportedById: map['reportedById'] ?? '',
      reportedId: map['reportedId'] ?? '',
      type: map['type'] ?? 'user',
      reason: map['reason'] ?? '',
      details: map['details'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
