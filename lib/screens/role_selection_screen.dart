import 'package:flutter/material.dart';
import 'package:untitled4/services/auth_service.dart';
import 'package:untitled4/screens/home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _saveRole() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);
    final res = await AuthService().setUserRole(_selectedRole!);
    setState(() => _isLoading = false);
    if (res['success'] == true) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (r) => false,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to set role')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select your role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RadioListTile<String>(
              title: const Text('User'),
              value: 'User',
              groupValue: _selectedRole,
              onChanged: (v) => setState(() => _selectedRole = v),
            ),
            RadioListTile<String>(
              title: const Text('Worker'),
              value: 'Worker',
              groupValue: _selectedRole,
              onChanged: (v) => setState(() => _selectedRole = v),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRole,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
