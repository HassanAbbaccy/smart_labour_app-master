import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled4/models/user_model.dart';
import 'package:untitled4/screens/worker_profile_screen.dart';

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
        title: Text(searchQuery ?? category),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1C18),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Worker')
            // Note: Cloud Firestore doesn't support simple substring search.
            // We will filter client-side for "searchQuery" or exact match for "category" if it's a profession.
            // For category, we might want to store 'profession' exactly.
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // Filter logic
          var workers = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return UserModel(
                  uid: doc.id,
                  email: data['email'] ?? '',
                  password: '',
                  firstName: data['firstName'] ?? '',
                  lastName: data['lastName'] ?? '',
                  phoneNumber: data['phoneNumber'] ?? '',
                  profession: data['profession'] ?? '',
                  role: data['role'],
                  rating: (data['rating'] ?? 0).toDouble(),
                  completedJobs: data['completedJobs'] ?? 0,
                );
              })
              .where((user) {
                bool match = true;
                // Category filter
                if (category != 'All' &&
                    category != 'More' &&
                    searchQuery == null) {
                  // Try to match profession loosely or mapped
                  // Assuming 'Electrician' maps to 'electrician' or 'Electrician'
                  match =
                      user.profession.toLowerCase() == category.toLowerCase();
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
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://i.pravatar.cc/150?u=${worker.uid}',
                    ), // Using UID for consistency
                    fit: BoxFit.cover,
                  ),
                ),
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
                        worker.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  Text(
                    worker.profession,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        worker.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${worker.completedJobs} jobs)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
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
