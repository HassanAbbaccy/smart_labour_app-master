import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MockGatewayScreen extends StatefulWidget {
  final String paymentMethod;
  final String amount;
  final String jobId;
  final String workerName;
  final String workerId;
  final String mobileNumber;

  const MockGatewayScreen({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.jobId,
    required this.workerName,
    required this.workerId,
    required this.mobileNumber,
  });

  @override
  State<MockGatewayScreen> createState() => _MockGatewayScreenState();
}

class _MockGatewayScreenState extends State<MockGatewayScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _processMockPayment() async {
    if (_pinController.text.length < 4) {
      setState(() => _errorMessage = 'Please enter a valid 4-digit PIN');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay and processing time
      await Future.delayed(const Duration(seconds: 3));

      // 1. Update Job Status to IN_ESCROW and assign worker
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({
            'paymentStatus': 'IN_ESCROW',
            'paymentMethod': widget.paymentMethod,
            'status': 'IN_PROGRESS',
            'workerId': widget.workerId,
            'workerName': widget.workerName,
          });

      // 2. Fetch workerId and Update Escrow Balance securely
      final cleanAmount = widget.amount.replaceAll(RegExp(r'[^0-9.]'), '');
      final amt = double.tryParse(cleanAmount) ?? 0.0;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.workerId)
          .update({'escrowBalance': FieldValue.increment(amt)});

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Payment failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment of Rs. ${widget.amount} using ${widget.paymentMethod} was successful and is now held in secure Escrow. It will be released to ${widget.workerName} upon completion.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Pop Dialog, then pop Gateway, then pop PaymentScreen (total 3 pops back to previous screen or dashboard)
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.paymentMethod == 'JazzCash'
                      ? const Color(0xFFE65100)
                      : const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isJazzCash = widget.paymentMethod == 'JazzCash';
    final primaryColor = isJazzCash
        ? const Color(0xFFE65100)
        : const Color(0xFF2E7D32);
    final bgColor = isJazzCash
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.paymentMethod} Secure Payment',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Image.asset(
                'assets/images/logo_placeholder.png',
                height: 80,
                width: 80,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.payment, size: 80, color: primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Confirm Transaction',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please verify details for this transaction.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Account Number', widget.mobileNumber),
                  const Divider(height: 24),
                  _buildDetailRow('Receiver', widget.workerName),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Amount',
                    'Rs. ${widget.amount}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: InputDecoration(
                hintText: '----',
                labelText: 'Enter 4-Digit MPIN',
                floatingLabelAlignment: FloatingLabelAlignment.center,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processMockPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 14, color: Colors.grey),
                SizedBox(width: 6),
                Text(
                  'End-to-End Encrypted via Sandbox',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
