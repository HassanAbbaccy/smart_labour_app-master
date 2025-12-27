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
  String? _selectedOccupation;
  bool _isLoading = false;
  int _currentStep = 1; // 1: Role, 2: Occupation

  final List<String> _occupations = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Labour',
    'Cleaner',
    'Moving',
  ];

  Future<void> _saveRole() async {
    if (_selectedRole == null) return;

    if (_selectedRole == 'Worker' && _currentStep == 1) {
      setState(() => _currentStep = 2);
      return;
    }

    if (_selectedRole == 'Worker' && _selectedOccupation == null) return;

    setState(() => _isLoading = true);
    final res = await AuthService().setUserRole(
      _selectedRole!,
      profession: _selectedOccupation,
    );
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
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: _currentStep == 2
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => setState(() => _currentStep = 1),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Title
              Text(
                _currentStep == 1 ? 'Choose Your Role' : 'Select Your Trade',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C18),
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                _currentStep == 1
                    ? 'Select how you want to use SmartLabour'
                    : 'What is your main area of expertise?',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              if (_currentStep == 1) ...[
                // Employee Card
                _buildRoleCard(
                  title: 'Employee',
                  description: 'I want to hire skilled workers',
                  icon: Icons.business_center_outlined,
                  value: 'Employee',
                ),
                const SizedBox(height: 16),
                // Worker Card
                _buildRoleCard(
                  title: 'Worker',
                  description: 'I am looking for job opportunities',
                  icon: Icons.handyman_outlined,
                  value: 'Worker',
                ),
              ] else ...[
                Expanded(
                  child: ListView.separated(
                    itemCount: _occupations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final occ = _occupations[index];
                      final isSelected = _selectedOccupation == occ;
                      return ListTile(
                        onTap: () => setState(() => _selectedOccupation = occ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF00BCD4)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        tileColor: isSelected
                            ? const Color(0xFFE0F7FA).withValues(alpha: 0.3)
                            : Colors.white,
                        title: Text(
                          occ,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00BCD4),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],

              if (_currentStep == 1) const Spacer(),

              const SizedBox(height: 24),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading ||
                          _selectedRole == null ||
                          (_currentStep == 2 && _selectedOccupation == null))
                      ? null
                      : _saveRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentStep == 1 ? 'Continue' : 'Finish Setup',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE0F7FA).withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00BCD4)
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00BCD4)
                    : const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF004D40),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00BCD4),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
