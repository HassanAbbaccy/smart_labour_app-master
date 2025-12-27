import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import 'category_results_screen.dart';
import 'worker_profile_screen.dart';
import 'jobs_screen.dart';
import 'messages_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenBody(),
    const SearchScreen(),
    const JobsScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF009688), // Teal
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  String _currentAddress = 'Gulberg III, Lahore';
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final location = await LocationService().getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentAddress = location;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        setState(() {
          _currentAddress = 'Location Unavailable';
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text('Please sign in'));
        }

        if (user.role == 'Worker') {
          return _buildWorkerDashboard(user);
        } else {
          return _buildClientDashboard(user);
        }
      },
    );
  }

  Widget _buildWorkerDashboard(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    user.firstName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C18),
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=worker',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              _buildStatCard(
                'Earnings',
                'PKR ${user.monthlyEarnings}',
                Icons.payments_outlined,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Jobs',
                '${user.completedJobs}',
                Icons.work_outline,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Rating',
                '${user.rating}',
                Icons.star_outline,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Active Job / Incoming Requests
          const Text(
            'Job Invitations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .where('workerId', isEqualTo: user.uid)
                .where('status', isEqualTo: 'REQUESTED')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(
                  'No job invitations yet. When a client hires you, the request will appear here in real-time!',
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = JobModel.fromDoc(snapshot.data!.docs[index]);
                  return _buildRequestCard(job);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(JobModel job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.handyman_outlined,
                  color: Color(0xFF009688),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      job.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                job.pay,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF009688),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(job.id)
                        .update({'status': 'IN PROGRESS'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildClientDashboard(UserModel user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Location
            InkWell(
              onTap: _fetchLocation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF00BCD4),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentAddress,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00BCD4),
                            ),
                          ),
                          if (_isLoadingLocation)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                        ],
                      ),
                    ],
                  ),
                  _buildNotificationIcon(),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24.0),

            // Recent Activity
            _buildSectionHeader('Recent Activity', actionLabel: 'History'),
            const SizedBox(height: 8),
            _buildRecentActivityCard(),
            const SizedBox(height: 24.0),

            // Categories
            _buildSectionHeader(
              'Categories',
              actionLabel: 'See All',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CategoryResultsScreen(category: 'All'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCategoriesGrid(),
            const SizedBox(height: 24.0),

            // Top Rated Workers
            _buildSectionHeader(
              'Top Rated Workers',
              actionLabel: 'See All',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CategoryResultsScreen(category: 'All'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildTopRatedWorkers(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.black87),
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryResultsScreen(
                  category: 'Search',
                  searchQuery: value,
                ),
              ),
            );
          }
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search service or worker...',
          hintStyle: TextStyle(color: Colors.black45),
          icon: Icon(Icons.search, color: Colors.black45),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C18),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionLabel,
              style: const TextStyle(color: Color(0xFF00BCD4)),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivityCard() {
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flash_on_outlined,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Electrician Repair',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusBadge(
                          'In Progress',
                          Colors.brown,
                          const Color(0xFFFFF8E1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Today, 10:30 AM',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=a',
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ahmed R.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text('Track Job'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 8,
      childAspectRatio: 0.8,
      children: [
        _buildCategoryItem(
          'Electrician',
          Icons.flash_on_outlined,
          const Color(0xFFE3F2FD),
          const Color(0xFF1976D2),
        ),
        _buildCategoryItem(
          'Plumber',
          Icons.water_drop_outlined,
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
        ),
        _buildCategoryItem(
          'Carpenter',
          Icons.chair_outlined,
          const Color(0xFFFFF3E0),
          const Color(0xFFEF6C00),
        ),
        _buildCategoryItem(
          'Painter',
          Icons.format_paint_outlined,
          const Color(0xFFF3E5F5),
          const Color(0xFF7B1FA2),
        ),
        _buildCategoryItem(
          'Labour',
          Icons.build_outlined,
          const Color(0xFFFAFAFA),
          Colors.grey[700]!,
        ),
        _buildCategoryItem(
          'Cleaner',
          Icons.cleaning_services_outlined,
          const Color(0xFFFAFAFA),
          Colors.grey[700]!,
        ),
        _buildCategoryItem(
          'Moving',
          Icons.local_shipping_outlined,
          const Color(0xFFFAFAFA),
          Colors.grey[700]!,
        ),
        _buildCategoryItem(
          'More',
          Icons.grid_view,
          const Color(0xFFFAFAFA),
          Colors.grey[700]!,
          isIcon: false,
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    bool isIcon = true,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryResultsScreen(category: label),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isIcon
                ? Icon(icon, color: iconColor, size: 28)
                : Container(),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1C18),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopRatedWorkers() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Worker')
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Error loading workers: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            'No top-rated workers found. Create another account with the "Worker" role to see it appear here!',
          );
        }

        final workers = snapshot.data!.docs.map((doc) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Sort client-side to avoid Missing Index error in Firestore
        workers.sort((a, b) => b.rating.compareTo(a.rating));

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: workers.map((worker) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildWorkerCard(
                  worker.fullName,
                  worker.rating,
                  worker.completedJobs,
                  worker.avatarUrl ??
                      'https://i.pravatar.cc/150?u=${worker.uid}',
                  uid: worker.uid,
                  profession: worker.profession,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWorkerCard(
    String name,
    double rating,
    int jobs,
    String imageUrl, {
    String? uid,
    String? profession,
  }) {
    final workerUid = uid ?? name.hashCode.toString();
    final workerProfession = profession ?? 'Professional Worker';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                WorkerProfileScreen(
                  worker: UserModel(
                    uid: workerUid,
                    firstName: name.split(' ')[0],
                    lastName: name.split(' ').length > 1
                        ? name.split(' ')[1]
                        : '',
                    email: '',
                    password: '',
                    phoneNumber: '',
                    profession: workerProfession,
                    rating: rating,
                    completedJobs: jobs,
                  ),
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.95,
                        end: 1.0,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
          ),
        );
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'worker_image_$workerUid',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($jobs jobs)',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
