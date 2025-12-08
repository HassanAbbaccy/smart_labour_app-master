import 'package:flutter/material.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:untitled4/screens/signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  child: Text(
                    user != null && user.firstName.isNotEmpty
                        ? user.firstName[0]
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(user?.profession ?? ''),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text('Email'),
                subtitle: Text(user?.email ?? ''),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Phone'),
                subtitle: Text(user?.phoneNumber ?? ''),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // Simple demo for editing: open dialog to update firstName
                      final newName = await showDialog<String?>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController(
                            text: user?.firstName ?? '',
                          );
                          return AlertDialog(
                            title: const Text('Edit First Name'),
                            content: TextField(controller: controller),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  controller.text.trim(),
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newName != null && newName.isNotEmpty) {
                        await AuthService().updateUserProfile(
                          firstName: newName,
                        );
                        setState(() {});
                      }
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthService().signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
