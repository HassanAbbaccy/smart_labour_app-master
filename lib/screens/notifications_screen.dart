import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/auth_service.dart';
import '../services/job_service.dart';
import 'job_detail_screen.dart';
import '../models/job_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see notifications')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs
              .map((doc) => NotificationModel.fromDoc(doc))
              .toList();
              
          // Sort locally to avoid Firebase Missing Index errors
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notif) {
    return InkWell(
      onTap: () async {
        // Mark as read
        if (!notif.isRead) {
          await JobService().markNotificationAsRead(notif.id);
        }

        // Navigate based on type
        if ((notif.type == 'application' || notif.type == 'hiring') && notif.data != null && notif.data!['jobId'] != null) {
          // Fetch job and navigate to detail
          final jobDoc = await FirebaseFirestore.instance
              .collection('jobs')
              .doc(notif.data!['jobId'])
              .get();
          
          if (jobDoc.exists && context.mounted) {
            final job = JobModel.fromDoc(jobDoc);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailScreen(job: job),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconBackground(notif.type),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notif.type),
                color: _getIconColor(notif.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('hh:mm a').format(notif.timestamp),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.person_add_outlined;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'status_update':
        return Icons.info_outline;
      case 'hiring':
        return Icons.celebration_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getIconBackground(String type) {
    switch (type) {
      case 'application':
        return const Color(0xFFE8F5E9);
      case 'message':
        return const Color(0xFFE3F2FD);
      case 'hiring':
        return const Color(0xFFE0F2F1); // Teal
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'application':
        return Colors.green;
      case 'message':
        return Colors.blue;
      case 'hiring':
        return const Color(0xFF009688); // Teal
      default:
        return Colors.orange;
    }
  }
}
