import 'package:flutter/material.dart';
import 'package:untitled4/services/auth_service.dart';
import '../theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome${user != null ? ', ${user.firstName}' : ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text('Overview and quick access to features.'),
            const SizedBox(height: 20),
            // Placeholder quick cards
            Row(
              children: const [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Quick Stats'),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Recent Activity'),
                    ),
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
