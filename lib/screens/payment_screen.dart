import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mock_gateway_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentScreen extends StatefulWidget {
  final String jobId;
  final String amount;
  final String workerName;
  final String workerId;

  const PaymentScreen({
    super.key,
    required this.jobId,
    required this.amount,
    required this.workerName,
    required this.workerId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'EasyPaisa';
  bool isProcessing = false;
  final TextEditingController _mobileController = TextEditingController();

  Future<void> _processPayment() async {
    if ((selectedMethod == 'EasyPaisa' || selectedMethod == 'JazzCash') &&
        _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile number')),
      );
      return;
    }

    if (selectedMethod == 'EasyPaisa' || selectedMethod == 'JazzCash') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MockGatewayScreen(
            paymentMethod: selectedMethod,
            amount: widget.amount,
            jobId: widget.jobId,
            workerName: widget.workerName,
            workerId: widget.workerId,
            mobileNumber: _mobileController.text,
          ),
        ),
      );
    } else if (selectedMethod == 'Stripe (Card)') {
      setState(() => isProcessing = true);
      try {
        // 1. Aggressive Whole-Number Parsing with Prefix Handling
        String rawVal = widget.amount;
        
        // Strip "Rs." or "Rs" prefix (case-insensitive)
        String noPrefix = rawVal.toLowerCase().replaceAll('rs.', '').replaceAll('rs', '');
        
        // Take everything before a remaining dot (ignore any true decimals)
        String beforeDot = noPrefix.contains('.') ? noPrefix.split('.')[0] : noPrefix;
        
        // Remove everything that isn't a digit
        String cleanAmount = beforeDot.replaceAll(RegExp(r'[^0-9]'), '');
        double pkrAmount = double.tryParse(cleanAmount) ?? 0.0;
        
        // 2. Convert PKR to USD (Rate: 1 PKR = 0.0036 USD)
        const double pkrToUsdRate = 0.0036;
        double usdAmount = pkrAmount * pkrToUsdRate;
        
        // 3. Convert to Cents for Stripe
        int amountInCents = (usdAmount * 100).round();

        // 4. ON-SCREEN DEBUGGING (Comprehensive)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DEBUG | Raw: "$rawVal" | Clean: $cleanAmount | PKR: $pkrAmount | USD: \$${usdAmount.toStringAsFixed(2)}'),
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFF003366), // Deep blue for visibility
          ),
        );

        debugPrint('--- FINAL PARSING DEBUG ---');
        debugPrint('Raw Input: "$rawVal"');
        debugPrint('Before Dot: "$beforeDot"');
        debugPrint('Cleaned Digits: "$cleanAmount"');
        debugPrint('Final PKR: $pkrAmount');
        debugPrint('Cents to Stripe: $amountInCents');

        // 5. Validate Minimum $0.50 USD
        if (amountInCents < 50) {
          setState(() => isProcessing = false);
          // Don't return yet, let the user see the blue bar first if we want, 
          // but actually we must stop Stripe.
          return;
        }

        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
        final response = await callable.call({
          'amount': amountInCents,
          'currency': 'usd',
          'jobId': widget.jobId,
        });

        final clientSecret = response.data['clientSecret'];

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'SmartLabour',
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({
          'paymentStatus': 'IN_ESCROW',
          'paymentMethod': selectedMethod,
          'status': 'IN_PROGRESS', 
          'workerId': widget.workerId,
          'workerName': widget.workerName,
        });

        await FirebaseFirestore.instance.collection('users').doc(widget.workerId).update({'escrowBalance': FieldValue.increment(pkrAmount)});

        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          if (e is StripeException) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment cancelled or failed.'), backgroundColor: Colors.red));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Error: $e'), backgroundColor: Colors.red));
          }
        }
      } finally {
        if (mounted) setState(() => isProcessing = false);
      }
    } else {
      // For Bank Transfer or other methods
      setState(() => isProcessing = true);
      try {
        await Future.delayed(const Duration(seconds: 2));

        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .update({
              'paymentStatus': 'IN_ESCROW',
              'paymentMethod': selectedMethod,
              'status': 'IN_PROGRESS', // job starts!
              'workerId': widget.workerId,
              'workerName': widget.workerName,
            });

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => isProcessing = false);
      }
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
              'Your booking with ${widget.workerName} is confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF009688), Color(0xFF00BFA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF009688).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Booking for ${widget.workerName}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // EasyPaisa
            _buildPaymentMethod(
              'EasyPaisa',
              'Fast & Secure Pakistani Payment',
              'https://images.seeklogo.com/logo-png/43/1/easypaisa-logo-png_seeklogo-437435.png',
              const Color(0xFFE8F5E9),
              const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 12),

            // JazzCash
            _buildPaymentMethod(
              'JazzCash',
              'Pakistan\'s #1 Mobile Wallet',
              'https://seeklogo.com/images/J/jazz-cash-logo-829841302F-seeklogo.com.png',
              const Color(0xFFFFF3E0),
              const Color(0xFFE65100),
            ),
            const SizedBox(height: 12),

            // Bank Transfer
            _buildPaymentMethod(
              'Bank Transfer',
              'Any Local Bank of Pakistan',
              '',
              const Color(0xFFE3F2FD),
              const Color(0xFF1976D2),
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 12),

            // Stripe Card
            _buildPaymentMethod(
              'Stripe (Card)',
              'Pay securely with Debit/Credit Card',
              'https://images.fastcompany.net/image/upload/w_1280,f_auto,q_auto,fl_lossy/wp-cms/uploads/2021/04/p-1-stripe-logo-2021.jpg',
              const Color(0xFFF3E5F5),
              const Color(0xFF673AB7),
              icon: Icons.credit_card,
            ),

            if (selectedMethod == 'EasyPaisa' ||
                selectedMethod == 'JazzCash') ...[
              const SizedBox(height: 24),
              Text(
                '$selectedMethod Mobile Account',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '03XX XXXXXXX',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1C18),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
    String id,
    String subtitle,
    String logoUrl,
    Color bgColor,
    Color activeColor, {
    IconData? icon,
  }) {
    bool isSelected = selectedMethod == id;

    return InkWell(
      onTap: () => setState(() => selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Colors.grey.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon != null
                  ? Icon(icon, color: activeColor)
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/logo_placeholder.png',
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.payment, color: activeColor),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: activeColor)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
