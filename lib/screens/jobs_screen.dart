import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/auth_service.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().firebaseUser?.uid;
    final userRole = AuthService().currentUser?.role;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Jobs',
          style: TextStyle(
            color: Color(0xFF003829),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF00BFA5),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF00BFA5),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              labelPadding: const EdgeInsets.only(right: 24, bottom: 8),
              indicatorPadding: const EdgeInsets.only(right: 24),
              tabs: const [Text('Active'), Text('History'), Text('Drafts')],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobStream(uid, userRole, [
            'IN PROGRESS',
            'REQUESTED',
            'SCHEDULED',
          ]),
          _buildJobStream(uid, userRole, ['COMPLETED', 'CANCELLED']),
          const Center(child: Text('Drafts')),
        ],
      ),
    );
  }

  Widget _buildJobStream(String uid, String? role, List<String> statuses) {
    Query query = FirebaseFirestore.instance.collection('jobs');

    if (role == 'Worker') {
      query = query.where('workerId', isEqualTo: uid);
    } else {
      query = query.where('clientId', isEqualTo: uid);
    }

    query = query.where('status', whereIn: statuses);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No jobs found.'));
        }

        final jobs = snapshot.data!.docs
            .map((doc) => JobModel.fromDoc(doc))
            .toList();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _JobCard(job: jobs[index], isWorker: role == 'Worker');
          },
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final bool isWorker;

  const _JobCard({required this.job, required this.isWorker});

  @override
  Widget build(BuildContext context) {
    final status = job.status?.toUpperCase() ?? '';
    final isRequested = status == 'REQUESTED';
    final isInProgress = status == 'IN PROGRESS';

    Color statusColor = const Color(0xFFE0F2F1);
    Color statusTextColor = const Color(0xFF009688);

    if (isRequested) {
      statusColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFEF6C00);
    } else if (isInProgress) {
      statusColor = const Color(0xFFE0F7FA);
      statusTextColor = const Color(0xFF00BCD4);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.location,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.pay,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1C18),
                ),
              ),
              if (isWorker && isRequested)
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(job.id)
                        .update({'status': 'IN PROGRESS'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              if (isWorker && isInProgress)
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(job.id)
                        .update({'status': 'COMPLETED'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete'),
                ),
              if (!isWorker && isRequested)
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Cancel Request'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
