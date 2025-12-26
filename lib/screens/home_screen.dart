import 'package:flutter/material.dart';
import 'package:untitled4/screens/jobs_screen.dart';
import 'package:untitled4/screens/messages_screen.dart';
import 'package:untitled4/screens/search_screen.dart';
import 'package:untitled4/screens/profile_screen.dart';
import 'package:untitled4/services/location_service.dart';
import 'package:untitled4/screens/category_results_screen.dart';

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
  String _currentAddress = 'Gulberg III, Lahore'; // Default/Fallback
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Location
            InkWell(
              onTap: _fetchLocation, // Refresh on tap
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF8E1), // Light yellow
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.black87,
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1), // Light cream
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
                          category: 'Search', // Generic
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
            ),
            const SizedBox(height: 24.0),

            // Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C18),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'History',
                    style: TextStyle(color: Color(0xFF00BCD4)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Activity Card
            Container(
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'In Progress',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Today, 10:30 AM',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
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
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?u=a',
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ahmed R.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
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
            ),
            const SizedBox(height: 24.0),

            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C18),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Color(0xFF00BCD4)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
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
                  Icons.chair_outlined, // Approximate
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
            ),
            const SizedBox(height: 24.0),

            // Top Rated Workers
            const Text(
              'Top Rated Workers',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C18),
              ),
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildWorkerCard(
                    'Muhammad K.',
                    4.9,
                    124,
                    'https://i.pravatar.cc/150?u=w1',
                  ),
                  const SizedBox(width: 16),
                  _buildWorkerCard(
                    'Bilal A.',
                    4.8,
                    98,
                    'https://i.pravatar.cc/150?u=w2',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    bool isIcon = true,
  }) {
    // Made tappable
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
                : Container(), // For 'More' if complex, or just icon
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

  Widget _buildWorkerCard(
    String name,
    double rating,
    int jobs,
    String imageUrl,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
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
                  const Icon(Icons.star_border, size: 16, color: Colors.orange),
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
    );
  }
}
