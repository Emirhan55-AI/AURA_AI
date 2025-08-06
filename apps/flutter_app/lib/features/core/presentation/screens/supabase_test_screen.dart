import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';

/// Supabase connection test screen
class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  String _connectionStatus = 'Not tested';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Test 1: Basic connection
      final response = await supabase
          .from('profiles')
          .select('count')
          .limit(1);
      
      setState(() {
        _connectionStatus = '✅ Connection successful!\nURL: ${AppConstants.supabaseUrl}';
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Connection failed:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAuth() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing auth...';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Test authentication with email/password
      final response = await supabase.auth.signUp(
        email: 'test@example.com',
        password: 'test123456',
      );
      
      setState(() {
        _connectionStatus = '✅ Auth test successful!\nUser: ${response.user?.email}';
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Auth test failed:\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Supabase Connection Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _connectionStatus,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Test Database Connection'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testAuth,
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Test Authentication'),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Update .env file with your Supabase keys\n'
              '2. Restart the app\n'
              '3. Click "Test Database Connection" button\n'
              '4. If successful, click "Test Authentication"',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
