import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class VerificationScreen extends StatefulWidget {
  final UserModel user;
  const VerificationScreen({super.key, required this.user});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _cnicFront;
  File? _cnicBack;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final StorageService _storageService = StorageService();

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        if (isFront) {
          _cnicFront = File(image.path);
        } else {
          _cnicBack = File(image.path);
        }
      });
    }
  }

  Future<void> _submitForVerification() async {
    if (_cnicFront == null || _cnicBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both CNIC Front and Back images'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload Front
      final frontUrl = await _storageService.uploadFile(
        file: _cnicFront!,
        path: 'verifications/${widget.user.uid}/cnic_front.jpg',
      );

      // 2. Upload Back
      final backUrl = await _storageService.uploadFile(
        file: _cnicBack!,
        path: 'verifications/${widget.user.uid}/cnic_back.jpg',
      );

      if (frontUrl == null || backUrl == null) {
        throw Exception('Failed to upload one or more images');
      }

      // 3. Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
            'verificationStatus': 'pending',
            'cnicFrontUrl': frontUrl,
            'cnicBackUrl': backUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification documents submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: const Text('Profile Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1C18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Become a Verified Pro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your Identity Card (CNIC) images to build trust with clients and get verified.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('CNIC Front Side'),
            const SizedBox(height: 12),
            _buildImagePickerCard(
              file: _cnicFront,
              onTap: () => _pickImage(true),
              label: 'Upload CNIC Front',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('CNIC Back Side'),
            const SizedBox(height: 12),
            _buildImagePickerCard(
              file: _cnicBack,
              onTap: () => _pickImage(false),
              label: 'Upload CNIC Back',
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitForVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit for Verification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1C18),
      ),
    );
  }

  Widget _buildImagePickerCard({
    required File? file,
    required VoidCallback onTap,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
          image: file != null
              ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
              : null,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
      ),
    );
  }
}
