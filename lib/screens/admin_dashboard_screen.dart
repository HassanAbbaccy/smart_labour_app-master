import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      length: 2,
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
              Tab(icon: Icon(Icons.verified_user), text: 'Verifications'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Withdrawals'),
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
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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
          // TAB 1: Verifications
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
          
          // TAB 2: Withdrawals
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('withdrawals')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No pending withdrawals'));
              }

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
          ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(title: Text(label), backgroundColor: Colors.black),
                  Image.asset('assets/images/service_placeholder.png', fit: BoxFit.contain),
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
                child: Image.asset('assets/images/service_placeholder.png', fit: BoxFit.cover),
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
}
