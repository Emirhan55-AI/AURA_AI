import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/providers/supabase_provider.dart';
import 'lib/core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment variables
  await AppConstants.initialize();
  
  // Initialize Supabase client
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  runApp(const ProviderScope(child: SupabaseIntegrationTestApp()));
}

class SupabaseIntegrationTestApp extends StatelessWidget {
  const SupabaseIntegrationTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Integration Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SupabaseTestScreen(),
    );
  }
}

class SupabaseTestScreen extends ConsumerStatefulWidget {
  const SupabaseTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends ConsumerState<SupabaseTestScreen> {
  String _status = 'Starting...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runIntegrationTest();
  }

  Future<void> _runIntegrationTest() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Supabase connection...';
    });

    try {
      // Test 1: Check Supabase service
      final supabaseService = ref.read(supabaseServiceProvider);
      setState(() {
        _status = '✅ Supabase service initialized\n';
      });

      // Test 2: Check authentication
      final user = supabaseService.client.auth.currentUser;
      setState(() {
        _status += user != null 
          ? '✅ User authenticated: ${user.email}\n'
          : '❌ No user authenticated\n';
      });

      // Test 3: Check database connection
      try {
        final response = await supabaseService.client
            .from('clothing_items')
            .select('id')
            .limit(1);
        
        setState(() {
          _status += '✅ Database connection working\n';
          _status += 'Response: ${response.toString()}\n';
        });
      } catch (e) {
        setState(() {
          _status += '❌ Database connection error: $e\n';
        });
      }

      setState(() {
        _status += '\n🎉 Basic integration test completed!';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status += '❌ Error: $e\n';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Integration Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase Integration Status:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Center(
                child: ElevatedButton(
                  onPressed: _runIntegrationTest,
                  child: const Text('Run Test Again'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
