import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_labour/models/user_model.dart';
import 'package:smart_labour/screens/worker_profile_screen.dart';
import '../widgets/custom_image_view.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import '../services/location_service.dart';

class CategoryResultsScreen extends StatelessWidget {
  final String category;
  final String? searchQuery;

  const CategoryResultsScreen({
    super.key,
    required this.category,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: Text(searchQuery != null ? searchQuery! : tr(category.toLowerCase())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1C18),
      ),
      body: ValueListenableBuilder<Position?>(
        valueListenable: LocationService().currentPosition,
        builder: (context, currentPos, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Worker')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // Filter logic
              var workers = snapshot.data!.docs
                  .map(
                    (doc) => UserModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .where((user) {
                    bool match = true;
                    // Category filter
                    if (category != 'All' &&
                        category != 'More' &&
                        searchQuery == null) {
                      match = user.profession.toLowerCase() == category.toLowerCase();
                    }

                    // Search query filter
                    if (searchQuery != null && searchQuery!.isNotEmpty) {
                      final query = searchQuery!.toLowerCase();
                      match =
                          user.fullName.toLowerCase().contains(query) ||
                          user.profession.toLowerCase().contains(query) ||
                          user.skills.any((s) => s.toLowerCase().contains(query));
                    }

                    return match;
                  })
                  .toList();

              // Distance Calculation and Sorting
              final currentUser = AuthService().currentUser;
              for (var w in workers) {
                if (w.lastLatitude != null && w.lastLongitude != null) {
                  // prioritize real-time local position over Firestore profile data
                  final lat = currentPos?.latitude ?? currentUser?.lastLatitude;
                  final lng = currentPos?.longitude ?? currentUser?.lastLongitude;

                  if (lat != null && lng != null) {
                    double distanceInMeters = Geolocator.distanceBetween(
                      lat,
                      lng,
                      w.lastLatitude!,
                      w.lastLongitude!,
                    );
                    w.tempDistance = distanceInMeters / 1000.0;
                  }
                } else {
                  w.tempDistance = double.maxFinite;
                }
              }
              
              workers.sort((a, b) => (a.tempDistance ?? double.maxFinite)
                  .compareTo(b.tempDistance ?? double.maxFinite));

              if (workers.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: workers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return _buildWorkerCard(context, worker);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No workers found for "$category"',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, UserModel worker) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                WorkerProfileScreen(worker: worker),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'worker_image_${worker.uid}',
              child: CustomImageView(
                url: worker.avatarUrl,
                width: 60,
                height: 60,
                borderRadius: 12,
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
                      Row(
                        children: [
                          Text(
                            worker.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (worker.rating >= 4.5) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'TOP RATED',
                                style: TextStyle(
                                  color: Color(0xFF009688),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${worker.hourlyRate.toInt()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF009688),
                            ),
                          ),
                          Text(
                            '/${tr('pay').toLowerCase()}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    worker.profession,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        worker.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      if (worker.tempDistance != null && worker.tempDistance != double.maxFinite) ...[
                        Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${worker.tempDistance!.toStringAsFixed(1)} ${tr('km_away')}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
