import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class WithdrawalScreen extends StatefulWidget {
  final UserModel user;

  const WithdrawalScreen({super.key, required this.user});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountTitleController = TextEditingController();

  String _selectedMethod = 'EasyPaisa';
  bool _isSubmitting = false;
  double _requestedAmount = 0.0;

  final List<String> _methods = ['EasyPaisa', 'JazzCash', 'Bank Transfer'];
  final double _platformFeePercent = 0.05; // 5% fee

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        _requestedAmount = double.tryParse(_amountController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountTitleController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal(double currentWalletBalance) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_requestedAmount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum withdrawal amount is Rs. 500'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_requestedAmount > currentWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient wallet balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final platformFee = _requestedAmount * _platformFeePercent;
      final amountPayout = _requestedAmount - platformFee;

      // 1. Create Withdrawal Record
      await FirebaseFirestore.instance.collection('withdrawals').add({
        'workerId': widget.user.uid,
        'workerName': widget.user.fullName,
        'amountRequested': _requestedAmount,
        'platformFee': platformFee,
        'amountPayout': amountPayout,
        'paymentMethod': _selectedMethod,
        'accountNumber': _accountNumberController.text.trim(),
        'accountTitle': _accountTitleController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Deduct Balance immediately to prevent double spending
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'walletBalance': FieldValue.increment(-_requestedAmount)});

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal Request Submitted!'),
          backgroundColor: Colors.green,
        ),
      );

      _amountController.clear();
      _accountNumberController.clear();
      _accountTitleController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: const Text(
          'My Wallet & Withdrawals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final currentBalance = (userData['walletBalance'] ?? 0.0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                _buildBalanceCard(currentBalance),
                const SizedBox(height: 24),

                // Form Section
                const Text(
                  'Request Withdrawal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildWithdrawalForm(currentBalance),
                const SizedBox(height: 32),

                // History Section
                const Text(
                  'Withdrawal History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildHistoryList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF009688),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'PKR ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(double currentBalance) {
    double platformFee = _requestedAmount * _platformFeePercent;
    double expectedPayout = _requestedAmount - platformFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Withdrawal Amount (Rs)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Enter amount';
                }
                double? val = double.tryParse(v);
                if (val == null) {
                  return 'Invalid amount';
                }
                if (val < 500) {
                  return 'Minimum is Rs. 500';
                }
                if (val > currentBalance) {
                  return 'Exceeds balance';
                }
                return null;
              },
            ),
            if (_requestedAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform Fee (5%)',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                        Text(
                          '- Rs. ${platformFee.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You will receive',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs. ${expectedPayout.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Receive Method',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              items: _methods
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMethod = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Account / Mobile Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountTitleController,
              decoration: const InputDecoration(
                labelText: 'Account Title (Name)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting || currentBalance < 500
                    ? null
                    : () => _submitWithdrawal(currentBalance),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
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

  Widget _buildHistoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('withdrawals')
          .where('workerId', isEqualTo: widget.user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text(
            'No past withdrawals',
            style: TextStyle(color: Colors.grey),
          );
        }

        // Sort locally to avoid Missing Index error
        final list = docs.toList();
        list.sort((a, b) {
          final aTime = (a.data() as Map)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map)['createdAt'] as Timestamp?;
          return (bTime ?? Timestamp.now()).compareTo(aTime ?? Timestamp.now());
        });

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = list[index].data() as Map<String, dynamic>;
            final isPending = data['status'] == 'pending';
            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp != null
                ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
                : 'Recent';

            return ListTile(
              contentPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              tileColor: Colors.white,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPending ? Icons.pending_actions : Icons.check_circle,
                  color: isPending ? Colors.orange : Colors.green,
                ),
              ),
              title: Text(
                'Rs. ${data['amountRequested']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${data['paymentMethod']} \n$date'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isPending ? 'Pending' : 'Completed',
                    style: TextStyle(
                      color: isPending ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fee: Rs. ${data['platformFee']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
