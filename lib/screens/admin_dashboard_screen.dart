import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/custom_image_view.dart';
import 'signin_screen.dart';
import '../models/report_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _userSearchController = TextEditingController();
  String _userSearchQuery = '';

  Future<void> _updateStatus(String uid, String status, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'verificationStatus': status,
        'isVerified': isVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${isVerified ? "Verified" : "Rejected"}'),
            backgroundColor: isVerified ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAF3),
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: const Color(0xFF009688),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.analytics_outlined), text: 'Analytics'),
              Tab(icon: Icon(Icons.people_outline), text: 'Users'),
              Tab(icon: Icon(Icons.report_problem_outlined), text: 'Reports'),
              Tab(icon: Icon(Icons.verified_user_outlined), text: 'Verifications'),
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Withdrawals'),
              Tab(icon: Icon(Icons.payments_outlined), text: 'Payments'),
            ],
          ),
          actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out Admin',
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirebaseFirestore.instance.collection('users').add({
            'firstName': 'Sample',
            'lastName': 'Worker',
            'profession': 'Electrician',
            'verificationStatus': 'pending',
            'isVerified': false,
            'cnicFrontUrl': 'https://via.placeholder.com/600x400?text=CNIC+Front',
            'cnicBackUrl': 'https://via.placeholder.com/600x400?text=CNIC+Back',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sample verification request added!')),
          );
        },
        backgroundColor: const Color(0xFF009688),
        tooltip: 'Add Sample Data',
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
      body: TabBarView(
        children: [
          // TAB 1: Analytics
          _buildAnalyticsTab(),

          // TAB 2: Users
          _buildUsersTab(),

          // TAB 3: Reports
          _buildReportsTab(),

          // TAB 4: Verifications
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('verificationStatus', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No pending verifications'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final user = UserModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                  return _buildUserCard(user);
                },
              );
            },
          ),
          
          // TAB 5: Withdrawals
          _buildWithdrawalsTab(),

          // TAB 6: Payments
          _buildPaymentsTab(),
        ],
      ),
    ),
   );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE0F2F1),
                  child: Text(user.firstName[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.profession,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'CNIC Images:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildImageThumbnail(user.cnicFrontUrl, 'Front'),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildImageThumbnail(user.cnicBackUrl, 'Back')),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(user.uid, 'rejected', false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(user.uid, 'verified', true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String? url, String label) {
    return GestureDetector(
      onTap: () {
        if (url != null) {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(label),
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  InteractiveViewer(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[900],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.white, size: 40),
                              SizedBox(height: 8),
                              Text('Failed to load image', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: url != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              )
            : Center(child: Text('No $label')),
      ),
    );
  }

  Widget _buildWithdrawalCard(String docId, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFF3E0),
                  child: Icon(Icons.account_balance_wallet, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['workerName'] ?? 'Unknown Employee'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Requested via ${data['paymentMethod'] ?? 'Unknown'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Amount requested'),
                    Text('Rs. ${data['amountRequested']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  const Divider(),
                   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Platform Fee'),
                    Text('Rs. ${data['platformFee']}', style: const TextStyle(color: Colors.red)),
                  ]),
                  const Divider(),
                   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Amount to Transfer'),
                    Text('Rs. ${data['amountPayout']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Transfer Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Account No: ${data['accountNumber'] ?? ''}'),
            Text('Account Title: ${data['accountTitle'] ?? ''}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _firestore.collection('withdrawals').doc(docId).update({
                      'status': 'completed',
                      'completedAt': FieldValue.serverTimestamp(),
                    });
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Completed!'), backgroundColor: Colors.green));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Mark as Transferred'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, userSnap) {
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('jobs').snapshots(),
                builder: (context, jobSnap) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('withdrawals').where('status', isEqualTo: 'completed').snapshots(),
                    builder: (context, payoutSnap) {
                      final totalUsers = userSnap.hasData ? userSnap.data!.docs.length : 0;
                      final totalJobs = jobSnap.hasData ? jobSnap.data!.docs.length : 0;
                      
                      double totalRevenue = 0;
                      if (payoutSnap.hasData) {
                        for (var doc in payoutSnap.data!.docs) {
                          totalRevenue += (doc.data() as Map<String, dynamic>)['platformFee'] ?? 0.0;
                        }
                      }

                      double totalEscrow = 0;
                      if (userSnap.hasData) {
                        for (var doc in userSnap.data!.docs) {
                          totalEscrow += (doc.data() as Map<String, dynamic>)['escrowBalance'] ?? 0.0;
                        }
                      }

                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard('Total Users', totalUsers.toString(), Icons.people, Colors.blue),
                          _buildStatCard('Total Jobs', totalJobs.toString(), Icons.work, Colors.orange),
                          _buildStatCard('Revenue', 'Rs. ${totalRevenue.toInt()}', Icons.trending_up, Colors.green),
                          _buildStatCard('In Escrow', 'Rs. ${totalEscrow.toInt()}', Icons.lock_clock, Colors.teal),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Recent Growth',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: Text(
                'Chart Placeholder\n(Growth data visualization)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _userSearchController,
            decoration: InputDecoration(
              hintText: 'Search users by name...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) {
              setState(() {
                _userSearchQuery = val.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data?.docs ?? [];
              
              if (_userSearchQuery.isNotEmpty) {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = '${data['firstName']} ${data['lastName']}'.toLowerCase();
                  return name.contains(_userSearchQuery);
                }).toList();
              }

              if (docs.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final role = data['role'] ?? 'Client';
                  final isVerified = data['isVerified'] ?? false;

                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: CircleAvatar(
                      backgroundColor: role == 'Worker' ? const Color(0xFFE0F2F1) : const Color(0xFFE3F2FD),
                      child: Icon(
                        role == 'Worker' ? Icons.engineering : Icons.person,
                        color: role == 'Worker' ? Colors.teal : Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text('${data['firstName']} ${data['lastName']}'),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Color(0xFF00BCD4), size: 14),
                        ],
                      ],
                    ),
                    subtitle: Text(role),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      _showUserDetailSheet(context, doc.id, data);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reports').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No reports filed yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final report = ReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            final isPending = report.status == 'pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: Icon(
                  report.type == 'user' ? Icons.person_outline : Icons.work_outline,
                  color: isPending ? Colors.orange : Colors.grey,
                ),
                title: Text(
                  '${report.reason} (${report.type})',
                  style: TextStyle(fontWeight: isPending ? FontWeight.bold : FontWeight.normal),
                ),
                subtitle: Text('Status: ${report.status.toUpperCase()}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details:', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(report.details),
                        const SizedBox(height: 12),
                        Text('Reported ID: ${report.reportedId}'),
                        Text('Reported By: ${report.reportedById}'),
                        const SizedBox(height: 16),
                        if (isPending)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await _firestore.collection('reports').doc(doc.id).update({'status': 'dismissed'});
                                },
                                child: const Text('Dismiss', style: TextStyle(color: Colors.grey)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  await _firestore.collection('reports').doc(doc.id).update({'status': 'resolved'});
                                  // In a real app, you might navigate to the user profile here
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Report marked as resolved')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688), foregroundColor: Colors.white),
                                child: const Text('Resolve'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDetailSheet(BuildContext context, String uid, Map<String, dynamic> data) {
    final role = data['role'] ?? 'Client';
    final isWorker = role == 'Worker';
    final isSuspended = data['isSuspended'] ?? false;
    final isFeatured = data['isFeatured'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CustomImageView(
                  url: data['avatarUrl'],
                  width: 60,
                  height: 60,
                  borderRadius: 30,
                  placeholder: isWorker ? 'assets/images/worker_placeholder.png' : 'assets/images/user_placeholder.png',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['firstName']} ${data['lastName']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        role,
                        style: TextStyle(color: isWorker ? Colors.teal : Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (isSuspended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                    child: const Text('SUSPENDED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            _buildDetailRow(Icons.email_outlined, 'Email', data['email'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.phone_outlined, 'Phone', data['phoneNumber'] ?? 'N/A'),
            const SizedBox(height: 16),
            if (isWorker) ...[
              _buildDetailRow(Icons.work_outline, 'Profession', data['profession'] ?? 'N/A'),
              const SizedBox(height: 16),
            ],
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Member Since',
              data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0] : 'Unknown',
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                if (isWorker) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _firestore.collection('users').doc(uid).update({'isFeatured': !isFeatured});
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFeatured ? Colors.orange[100] : Colors.grey[100],
                        foregroundColor: isFeatured ? Colors.orange[900] : Colors.grey[700],
                        elevation: 0,
                      ),
                      icon: Icon(isFeatured ? Icons.star : Icons.star_border),
                      label: Text(isFeatured ? 'Unfeature' : 'Feature'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _firestore.collection('users').doc(uid).update({'isSuspended': !isSuspended});
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuspended ? Colors.green[50] : Colors.red[50],
                      foregroundColor: isSuspended ? Colors.green : Colors.red,
                      elevation: 0,
                    ),
                    icon: Icon(isSuspended ? Icons.check_circle_outline : Icons.block),
                    label: Text(isSuspended ? 'Unsuspend' : 'Suspend'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildWithdrawalsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('withdrawals').where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No pending withdrawals'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildWithdrawalCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('jobs').where('paymentStatus', isEqualTo: 'WAITING_FOR_APPROVAL').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No pending payments'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final receiptUrl = data['receiptUrl'];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2F1), child: Icon(Icons.receipt_long, color: Colors.teal)),
                title: Text('Job: ${data['title'] ?? 'N/A'}'),
                subtitle: Text('Amount: Rs. ${data['paymentAmount'] ?? 'N/A'}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (receiptUrl != null) ...[
                          const Text('Payment Receipt:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              receiptUrl,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 100,
                                color: Colors.grey[200],
                                child: const Center(child: Text('Error loading image')),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // APPROVE: Set to HIRED and IN_ESCROW
                                  final workerId = data['workerId'];
                                  final amount = (data['paymentAmount'] ?? 0.0).toDouble();
                                  
                                  await _firestore.collection('jobs').doc(doc.id).update({
                                    'paymentStatus': 'IN_ESCROW',
                                    'status': 'HIRED',
                                  });

                                  if (workerId != null) {
                                    await _firestore.collection('users').doc(workerId).update({
                                      'escrowBalance': FieldValue.increment(amount),
                                    });
                                  }

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Approved!')));
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // REJECT: Reset to PENDING
                                  await _firestore.collection('jobs').doc(doc.id).update({
                                    'paymentStatus': 'PENDING',
                                    'receiptUrl': null,
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Rejected')));
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
