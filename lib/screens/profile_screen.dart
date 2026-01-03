import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:untitled4/screens/signin_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    final uid = AuthService().firebaseUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to upload photos')),
        );
      }
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Create storage reference
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('$uid.jpg');

      // Upload file
      final uploadTask = ref.putFile(File(image.path));

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final url = await snapshot.ref.getDownloadURL();

      // Update Firestore with new avatar URL
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatarUrl': url,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseException catch (e) {
      String errorMessage = 'Upload failed';

      if (e.code == 'object-not-found') {
        errorMessage =
            'Storage not configured. Please enable Firebase Storage in Firebase Console.';
      } else if (e.code == 'unauthorized') {
        errorMessage =
            'Permission denied. Please check Firebase Storage rules.';
      } else if (e.code == 'canceled') {
        errorMessage = 'Upload was cancelled';
      } else if (e.code == 'unknown') {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Upload failed: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showEditProfileDialog(Map<String, dynamic> userData) {
    final firstNameController = TextEditingController(
      text: userData['firstName'],
    );
    final lastNameController = TextEditingController(
      text: userData['lastName'],
    );
    final phoneController = TextEditingController(
      text: userData['phoneNumber'],
    );
    final rateController = TextEditingController(
      text: userData['hourlyRate']?.toString() ?? '1200',
    );
    final addressController = TextEditingController(text: userData['address']);
    final skillController = TextEditingController();
    List<String> tempSkills = List<String>.from(userData['skills'] ?? []);

    String? selectedProfession = userData['profession'];

    final List<String> occupations = [
      'Electrician',
      'Plumber',
      'Carpenter',
      'Painter',
      'Labour',
      'Cleaner',
      'Moving',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (PKR)',
                    prefixText: 'Rs. ',
                  ),
                ),
                if (userData['role'] == 'Worker') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: occupations.contains(selectedProfession)
                        ? selectedProfession
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Professional Category',
                      border: OutlineInputBorder(),
                    ),
                    items: occupations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedProfession = newValue;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Skills',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: tempSkills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          onDeleted: () {
                            setDialogState(() {
                              tempSkills.remove(skill);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: skillController,
                        decoration: const InputDecoration(
                          hintText: 'Add skill',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (skillController.text.isNotEmpty) {
                          setDialogState(() {
                            tempSkills.add(skillController.text.trim());
                            skillController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = AuthService().firebaseUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'phoneNumber': phoneController.text,
                      'address': addressController.text,
                      'hourlyRate':
                          double.tryParse(rateController.text) ?? 1200.0,
                      'skills': tempSkills,
                      if (userData['role'] == 'Worker')
                        'profession': selectedProfession,
                    });
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().firebaseUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please sign in to view profile'))
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('User data not found'));
                  }

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final displayName =
                      '${userData['firstName'] ?? "User"} ${userData['lastName'] ?? ""}';
                  final phoneNumber =
                      userData['phoneNumber'] ?? "+92 300 1234567";
                  final walletBalance = userData['walletBalance'] ?? 0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage: userData['avatarUrl'] != null
                                      ? NetworkImage(userData['avatarUrl'])
                                      : const NetworkImage(
                                          'https://i.pravatar.cc/150?u=profile',
                                        ),
                                  backgroundColor: Colors.grey[200],
                                ),
                                if (_isUploading)
                                  const Positioned.fill(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _isUploading
                                        ? null
                                        : _pickAndUploadImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00BCD4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                if (userData['address'] != null &&
                                    userData['address'].isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    userData['address'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _showEditProfileDialog(userData),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF00BCD4),
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
                            color: const Color(0xFF00BCD4),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00BCD4,
                                ).withValues(alpha: 0.3),
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
                              Text(
                                'PKR ${walletBalance.toString()}',
                                style: const TextStyle(
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
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Top Up'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
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

                        // Skills Section
                        if (userData['skills'] != null &&
                            (userData['skills'] as List).isNotEmpty) ...[
                          const Text(
                            'Professional Skills',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1C18),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (userData['skills'] as List)
                                .map(
                                  (skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00BCD4,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00BCD4,
                                        ).withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      skill.toString(),
                                      style: const TextStyle(
                                        color: Color(0xFF009688),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 32),
                        ],

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
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Sign Out',
                          iconColor: Colors.red.withValues(alpha: 0.1),
                          iconTextColor: Colors.red,
                          onTap: () {
                            AuthService().signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const SignInScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
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
