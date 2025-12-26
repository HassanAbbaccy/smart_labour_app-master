import 'package:flutter/material.dart';
import '../models/job_model.dart';

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

  // Dummy Data
  final List<JobModel> activeJobs = [
    JobModel(
      id: 'JB-29401',
      title: 'Switchboard Repair',
      description: 'Repair switchboard',
      location: 'Home • Gulberg III',
      pay: 'Rs. 1,200',
      createdAt:
          DateTime.now(), // Displayed as "Today, 2:30 PM" in UI logic (mocked)
      status: 'IN PROGRESS',
      workerName: 'Rashid Ali',
      workerAvatarUrl: 'https://i.pravatar.cc/150?u=1', // Mock avatar
      jobIconUrl: 'assets/icons/switchboard.png', // Mock icon
      isRangePrice: false,
    ),
    JobModel(
      id: 'JB-29408',
      title: 'Kitchen Tap Leak',
      description: 'Fix kitchen tap',
      location: 'Office • DHA Phase 5',
      pay: 'Rs. 500 - 800',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'REQUESTED',
      workersOffered: 3,
      isRangePrice: true,
      maxPrice: '800',
    ),
    JobModel(
      id: 'JB-29388',
      title: 'Door Hinge Fix',
      description: 'Fix door hinge',
      location: 'Home • Gulberg III',
      pay: 'Rs. 500', // Example price not in ss but needed for model
      createdAt: DateTime.now().add(const Duration(days: 1)), // Tomorrow
      status: 'SCHEDULED',
      workerName: 'Bilal Ahmed',
      workerAvatarUrl: 'https://i.pravatar.cc/150?u=2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3), // Surface color from theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Jobs',
          style: TextStyle(
            color: Color(0xFF003829), // Dark green/black
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
              labelColor: const Color(0xFF00BFA5), // Teal
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF00BFA5),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              labelPadding: const EdgeInsets.only(right: 24, bottom: 8),
              indicatorPadding: const EdgeInsets.only(right: 24),
              tabs: const [Text('Active (3)'), Text('History'), Text('Drafts')],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobList(activeJobs),
          const Center(child: Text('History')), // Placeholder
          const Center(child: Text('Drafts')), // Placeholder
        ],
      ),
    );
  }

  Widget _buildJobList(List<JobModel> jobs) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _JobCard(job: jobs[index]);
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final isRequested = job.status == 'REQUESTED';
    final isInProgress = job.status == 'IN PROGRESS';
    final isScheduled = job.status == 'SCHEDULED';

    Color statusColor = const Color(0xFFE0F2F1); // Light teal
    Color statusTextColor = const Color(0xFF009688); // Teal
    String statusText = job.status ?? '';

    if (isRequested) {
      statusColor = const Color(0xFFFFF3E0); // Light orange
      statusTextColor = const Color(0xFFEF6C00); // Orange
    } else if (isInProgress) {
      statusColor = const Color(0xFFE0F7FA); // Cyan 50
      statusTextColor = const Color(0xFF00BCD4); // Cyan
    } else if (isScheduled) {
      statusColor = const Color(0xFFE0F2F1);
      statusTextColor = const Color(0xFF009688);
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
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isScheduled
                      ? const Color(0xFFF3E5F5)
                      : const Color(0xFFFFF8E1), // Purple or Amber light
                  borderRadius: BorderRadius.circular(8),
                ),
                // Normally would use job.jobIconUrl
              ),
              const SizedBox(width: 12),
              Expanded(
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
                            statusText,
                            style: TextStyle(
                              color: statusTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${job.id}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date/Time
          if (isInProgress)
            const Text(
              'Today, 2:30 PM',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          if (isScheduled)
            const Text(
              'Tomorrow, 10:00 AM',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          if (isRequested)
            const Text(
              'Flexible Timing',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

          const SizedBox(height: 4),
          // Location
          Text(
            job.location,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Worker Info
          if (job.workerName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFFF8E1,
                ).withValues(alpha: 0.5), // Very light background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(job.workerAvatarUrl ?? ''),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    job.workerName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (isInProgress) ...[
                    _buildActionButton(Icons.call, Colors.white),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.chat_bubble_outline, Colors.white),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (isRequested && job.workersOffered != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${job.workersOffered} Workers offered',
                style: const TextStyle(
                  color: Color(0xFF00BCD4), // Cyan
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),

          // Bottom Row
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
              if (isInProgress)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Track Status'),
                ),
              if (isRequested)
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1C18),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('View Offers'),
                ),
              if (isScheduled)
                Container(), // No button shown in design crop for 3rd card, or implied same as others?
              // Actually the 3rd card is cut off at the bottom. The first one has Track Status, 2nd has View Offers.
              // I'll leave it empty for now or maybe add a "View" button.
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color bg) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }
}
