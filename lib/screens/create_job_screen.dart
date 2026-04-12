import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/job_service.dart';
import '../models/job_model.dart';
import '../services/location_service.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final loc = await LocationService().getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationController.text = loc;
        });
      }
    } catch (e) {
       // fallback
    }
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final newJob = JobModel(
        id: '', // Firestore auto-generates
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        pay: 'Rs. ${_payController.text.trim()}',
        status: 'OPEN', // explicitly broadcasting for applications
        clientId: currentUser.uid,
        workerId: null, // no worker assigned yet
        paymentStatus: 'PENDING',
      );

      await JobService().createJob(newJob);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully! It is now on the feed.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: const Text('Post a New Job'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
           key: _formKey,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text(
                 'Find the perfect worker',
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 8),
               Text(
                 'Post your job details to the live feed and start receiving applications.',
                 style: TextStyle(color: Colors.grey[600], fontSize: 16),
               ),
               const SizedBox(height: 32),
               
               TextFormField(
                 controller: _titleController,
                 validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                 decoration: const InputDecoration(
                   labelText: 'Job Title',
                   hintText: 'e.g. Need an Electrician for wiring',
                   border: OutlineInputBorder(),
                 ),
               ),
               const SizedBox(height: 20),
               TextFormField(
                 controller: _descriptionController,
                 validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                 maxLines: 4,
                 decoration: const InputDecoration(
                   labelText: 'Job Description',
                   hintText: 'Explain what needs to be done...',
                   border: OutlineInputBorder(),
                 ),
               ),
               const SizedBox(height: 20),
               TextFormField(
                 controller: _locationController,
                 validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                 decoration: const InputDecoration(
                   labelText: 'Location',
                   hintText: 'Where is the job?',
                   border: OutlineInputBorder(),
                 ),
               ),
               const SizedBox(height: 20),
               TextFormField(
                 controller: _payController,
                 validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                 keyboardType: TextInputType.number,
                 decoration: const InputDecoration(
                   labelText: 'Budget (Rs.)',
                   hintText: 'e.g. 5000',
                   border: OutlineInputBorder(),
                   prefixText: 'Rs. ',
                 ),
               ),
               const SizedBox(height: 40),
               SizedBox(
                 width: double.infinity,
                 height: 56,
                 child: ElevatedButton(
                   onPressed: _isLoading ? null : _postJob,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF009688),
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     )
                   ),
                   child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Post to Feed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 ),
               )
             ]
           )
        )
      )
    );
  }
}
