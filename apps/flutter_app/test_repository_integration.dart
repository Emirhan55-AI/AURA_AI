import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
    print('✅ Supabase initialized for repository testing');
  } catch (e) {
    print('❌ Initialization error: $e');
  }
  
  runApp(const RepositoryTestApp());
}

class RepositoryTestApp extends StatelessWidget {
  const RepositoryTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repository Integration Test',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const RepositoryTestScreen(),
    );
  }
}

class RepositoryTestScreen extends StatefulWidget {
  const RepositoryTestScreen({super.key});

  @override
  State<RepositoryTestScreen> createState() => _RepositoryTestScreenState();
}

class _RepositoryTestScreenState extends State<RepositoryTestScreen> {
  String _authStatus = 'Not authenticated';
  String _crudStatus = 'Not tested';
  String _realtimeStatus = 'Not tested';
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      if (session != null) {
        _authStatus = '✅ Authenticated as: ${session.user.email}';
        _userId = session.user.id;
      } else {
        _authStatus = '⚠️ Not authenticated (Anonymous access)';
      }
    });
  }

  Future<void> _testAnonymousSignIn() async {
    setState(() {
      _isLoading = true;
      _authStatus = 'Attempting anonymous sign in...';
    });

    try {
      // Test anonymous user creation for testing
      final response = await Supabase.instance.client.auth.signInAnonymously();
      
      setState(() {
        _authStatus = '✅ Anonymous user created: ${response.user?.id}';
        _userId = response.user?.id;
      });
      
      await _testCrudOperations();
    } catch (e) {
      setState(() {
        _authStatus = '❌ Anonymous sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCrudOperations() async {
    if (_userId == null) {
      setState(() {
        _crudStatus = '❌ No user ID available for CRUD test';
      });
      return;
    }

    setState(() {
      _crudStatus = 'Testing CRUD operations...';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Test 1: Insert a user record
      try {
        await supabase.from('users').insert({
          'id': _userId,
          'email': 'test-${DateTime.now().millisecondsSinceEpoch}@aura.com',
          'full_name': 'Test User',
          'username': 'testuser${DateTime.now().millisecondsSinceEpoch}',
          'bio': 'Test user created by repository test'
        });
        
        setState(() {
          _crudStatus = '✅ User record created successfully\n';
        });
      } catch (e) {
        setState(() {
          _crudStatus = '⚠️ User creation: $e\n';
        });
      }

      // Test 2: Insert a clothing item
      try {
        final itemResponse = await supabase.from('clothing_items').insert({
          'user_id': _userId,
          'name': 'Test T-Shirt',
          'category': 'Top',
          'color': 'Blue',
          'brand': 'Test Brand',
          'notes': 'Created by repository test'
        }).select();

        setState(() {
          _crudStatus += '✅ Clothing item created: ${itemResponse.length} records\n';
        });
      } catch (e) {
        setState(() {
          _crudStatus += '❌ Clothing item creation failed: $e\n';
        });
      }

      // Test 3: Query user's items
      try {
        final items = await supabase
            .from('clothing_items')
            .select('*')
            .eq('user_id', _userId!);

        setState(() {
          _crudStatus += '✅ Query successful: Found ${items.length} clothing items\n';
        });
      } catch (e) {
        setState(() {
          _crudStatus += '❌ Query failed: $e\n';
        });
      }

      // Test 4: Create a combination
      try {
        await supabase.from('combinations').insert({
          'user_id': _userId,
          'name': 'Test Outfit',
          'description': 'Test combination created by repository test',
          'is_public': true
        });

        setState(() {
          _crudStatus += '✅ Combination created successfully\n';
        });
      } catch (e) {
        setState(() {
          _crudStatus += '❌ Combination creation failed: $e\n';
        });
      }

    } catch (e) {
      setState(() {
        _crudStatus = '❌ CRUD test failed: $e';
      });
    }
  }

  Future<void> _testRealtimeConnection() async {
    setState(() {
      _realtimeStatus = 'Testing realtime connection...';
    });

    try {
      final channel = Supabase.instance.client.channel('test-channel');
      
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'combinations',
        callback: (payload) {
          setState(() {
            _realtimeStatus += '\n📡 Realtime event received: ${payload.eventType}';
          });
        },
      );

      await channel.subscribe();

      setState(() {
        _realtimeStatus = '✅ Realtime channel subscribed successfully\n';
      });
      
      // Test realtime by creating a public combination
      if (_userId != null) {
        await Supabase.instance.client.from('combinations').insert({
          'user_id': _userId,
          'name': 'Realtime Test Outfit',
          'description': 'Testing realtime functionality',
          'is_public': true
        });
      }

    } catch (e) {
      setState(() {
        _realtimeStatus = '❌ Realtime test failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repository Integration Tests', 
                         style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Testing Flutter app integration with Supabase database'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Test Results', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusSection('Authentication Status', _authStatus),
                              const SizedBox(height: 16),
                              _buildStatusSection('CRUD Operations', _crudStatus),
                              const SizedBox(height: 16),
                              _buildStatusSection('Realtime Connection', _realtimeStatus),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _testAnonymousSignIn,
                    child: const Text('Test Auth & CRUD'),
                  ),
                  ElevatedButton(
                    onPressed: _testRealtimeConnection,
                    child: const Text('Test Realtime'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(String title, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status.startsWith('✅') ? Colors.green[700] 
                   : status.startsWith('❌') ? Colors.red[700]
                   : status.startsWith('⚠️') ? Colors.orange[700]
                   : Colors.blue[700],
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
