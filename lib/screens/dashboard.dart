import 'package:flutter/material.dart';
import 'package:untitled4/widgets/custom_scaffold.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:untitled4/screens/signin_screen.dart';
import 'package:untitled4/screens/home_screen.dart';
import 'package:untitled4/screens/jobs_screen.dart';
import 'package:untitled4/screens/messages_screen.dart';
import 'package:untitled4/screens/profile_screen.dart';

// Color scheme
const Color primaryPurple = Color(0xFF7C3AED);
const Color accentSkyBlue = Color(0xFF0EA5E9);
const Color lightSkyBlue = Color(0xFFE0F2FE);
const Color lightPurple = Color(0xFFF3E8FF);

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 3; // default to Dashboard tab index

  Future<void> _handleSignOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  Widget _buildWelcomeSection() {
    final user = AuthService().currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryPurple, accentSkyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 6),
                Text(
                  user != null ? '${user.firstName} ${user.lastName}' : 'User',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.profession ?? 'Professional',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  user != null && user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final user = AuthService().currentUser;
    return Row(
      children: [
        _statCard('Active', '${user?.activeJobs ?? 0}', primaryPurple, Icons.work),
        const SizedBox(width: 12),
        _statCard('Completed', '${user?.completedJobs ?? 0}', accentSkyBlue, Icons.check_circle),
        const SizedBox(width: 12),
        _statCard('Earnings', '\$${user?.monthlyEarnings?.toStringAsFixed(0) ?? '0'}', Colors.green, Icons.attach_money),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsPreview() {
    final jobs = [
      {'title': 'House Cleaning', 'location': 'Downtown', 'pay': '\$45/hr'},
      {'title': 'Plumbing Repair', 'location': 'Midtown', 'pay': '\$60/hr'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...jobs.map((j) => Card(
              child: ListTile(
                title: Text(j['title']!),
                subtitle: Text('${j['location']} · ${j['pay']}'),
                trailing: ElevatedButton(onPressed: () {}, child: const Text('Apply')),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SmartLabour'),
          centerTitle: true,
          backgroundColor: primaryPurple,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 20),
              _buildStatCards(),
              const SizedBox(height: 20),
              _buildJobsPreview(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            switch (index) {
              case 0:
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
                break;
              case 1:
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobsScreen()));
                break;
              case 2:
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MessagesScreen()));
                break;
              case 3:
                // already on Dashboard
                break;
              case 4:
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                break;
            }
          },
          selectedItemColor: primaryPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:untitled4/widgets/custom_scaffold.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:untitled4/screens/signin_screen.dart';

// Color scheme
const Color primaryPurple = Color(0xFF7C3AED);
const Color accentSkyBlue = Color(0xFF0EA5E9);
const Color lightSkyBlue = Color(0xFFE0F2FE);
const Color lightPurple = Color(0xFFF3E8FF);

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SmartLabour'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('SmartLabour'),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                ),
                // Keep the existing dashboard content as the default body.
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Section
                        _buildWelcomeSection(),
                        const SizedBox(height: 24),
                        // Quick Stats
                        _buildQuickStats(),
                        const SizedBox(height: 24),
                        // Available Jobs Section
                        _buildAvailableJobsSection(),
                        const SizedBox(height: 24),
                        // My Active Tasks
                        _buildActiveTasksSection(),
                        const SizedBox(height: 24),
                        // Recommended Services
                        _buildRecommendedServicesSection(),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    // Navigate to the selected screen (push routes so users can come back)
                    switch (index) {
                      case 0:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
                        break;
                      case 1:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobsScreen()));
                        break;
                      case 2:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MessagesScreen()));
                        break;
                      case 3:
                        // Dashboard (current) — do nothing
                        break;
                      case 4:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        break;
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
                    BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                  ],
                ),
              ),
            );
        gradient: LinearGradient(
          colors: [primaryPurple, accentSkyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.firstName ?? 'User',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.profession ?? 'Professional',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user?.firstName.isNotEmpty == true
                            ? user!.firstName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          '${user?.rating ?? 4.5}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.work_outline),
                  label: const Text(
                    'Find Jobs',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildQuickStats() {
    final user = AuthService().currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              'Active Jobs',
              '${user?.activeJobs ?? 0}',
              primaryPurple,
              Icons.work,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Completed',
              '${user?.completedJobs ?? 0}',
              accentSkyBlue,
              Icons.check_circle,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Earnings',
              '\$${user?.monthlyEarnings.toStringAsFixed(0) ?? 0}',
              Colors.green,
              Icons.trending_up,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableJobsSection() {
    final jobs = [
      {
        'title': 'House Cleaning',
        'location': 'Downtown',
        'pay': '\$45/hr',
        'icon': Icons.cleaning_services,
        'rating': 4.8,
      },
      {
        'title': 'Plumbing Repair',
        'location': 'Midtown',
        'pay': '\$60/hr',
        'icon': Icons.plumbing,
        'rating': 4.9,
      },
      {
        'title': 'Tutoring Service',
        'location': 'Uptown',
        'pay': '\$50/hr',
        'icon': Icons.school,
        'rating': 4.7,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(color: primaryPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildJobCard(job);
          },
        ),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryPurple.withOpacity(0.2),
                    accentSkyBlue.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(job['icon'] as IconData, color: primaryPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        job['location'] as String,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        job['rating'].toString(),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  job['pay'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTasksSection() {
    final tasks = [
      {
        'title': 'Office Cleaning',
        'client': 'ABC Corp',
        'progress': 0.75,
        'status': '75% Complete',
      },
      {
        'title': 'Website Maintenance',
        'client': 'Tech Startup',
        'progress': 0.50,
        'status': '50% Complete',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Active Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskCard(task);
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentSkyBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task['status'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: accentSkyBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Client: ${task['client']}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: task['progress'] as double,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(accentSkyBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedServicesSection() {
    final services = [
      {'name': 'Plumber', 'icon': Icons.plumbing, 'color': accentSkyBlue},
      {'name': 'Electrician', 'icon': Icons.flash_on, 'color': Colors.amber},
      {
        'name': 'Cleaner',
        'icon': Icons.cleaning_services,
        'color': Colors.green,
      },
      {'name': 'Carpenter', 'icon': Icons.carpenter, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(service);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: (service['color'] as Color).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (service['color'] as Color).withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: (service['color'] as Color).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                service['icon'] as IconData,
                color: service['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service['name'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
