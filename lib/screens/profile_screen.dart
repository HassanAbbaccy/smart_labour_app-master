import 'package:flutter/material.dart';
import 'package:untitled4/screens/home_screen.dart';
import 'package:untitled4/screens/jobs_screen.dart';
import 'package:untitled4/screens/messages_screen.dart';
import 'package:untitled4/screens/search_screen.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:untitled4/screens/signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 4; // Profile tab index

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = '${user?.firstName ?? "User"} ${user?.lastName ?? ""}';
    final phoneNumber =
        user?.phoneNumber ?? "+92 300 1234567"; // Fallback to image ex
    // Note: Wallet balance is static as per plan

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/150?u=profile', // Placeholder
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C18),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00BCD4), // Cyan
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Wallet Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4), // Cyan
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Wallet Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PKR 4,250',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Top Up'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('History'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Menu Items
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'My Addresses',
                iconColor: const Color(0xFFE0F2F1),
                iconTextColor: const Color(0xFF009688),
              ),
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Saved Workers',
                iconColor: const Color(0xFFF3E5F5),
                iconTextColor: Colors.purple,
              ),
              _buildMenuItem(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                iconColor: const Color(0xFFE3F2FD),
                iconTextColor: Colors.blue,
              ),
              _buildMenuItem(
                icon: Icons.language,
                title: 'Language',
                iconColor: const Color(0xFFFFF3E0),
                iconTextColor: Colors.orange,
                trailing: const Text(
                  'English',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                iconColor: const Color(0xFFE8F5E9),
                iconTextColor: Colors.green,
              ),
              _buildMenuItem(
                icon: Icons.description_outlined,
                title: 'Terms & Privacy',
                iconColor: const Color(0xFFFFEBEE),
                iconTextColor: Colors.red,
              ),

              const SizedBox(height: 24),
              // Sign Out added as a list item for functionality
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Sign Out',
                iconColor: Colors.red.withValues(alpha: 0.1),
                iconTextColor: Colors.red,
                onTap: () {
                  AuthService().signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconTextColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconTextColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1C18),
        ),
      ),
      trailing: trailing,
    );
  }
}
