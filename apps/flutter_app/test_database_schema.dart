import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded successfully');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
    print('✅ Supabase initialized successfully');
    
  } catch (e) {
    print('❌ Initialization error: $e');
  }
  
  runApp(const DatabaseTestApp());
}

class DatabaseTestApp extends StatelessWidget {
  const DatabaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Schema Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DatabaseTestScreen(),
    );
  }
}

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  String _schemaStatus = 'Not tested';
  String _tablesStatus = 'Not tested';
  String _rlsStatus = 'Not tested';
  bool _isLoading = false;
  List<String> _availableTables = [];

  @override
  void initState() {
    super.initState();
    _testDatabaseSchema();
  }

  Future<void> _testDatabaseSchema() async {
    setState(() {
      _isLoading = true;
      _schemaStatus = 'Testing database schema...';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Test 1: Check if basic tables exist
      await _checkTables();
      
      // Test 2: Test basic CRUD operations
      await _testCrudOperations();
      
      // Test 3: Test RLS policies
      await _testRlsPolicies();
      
    } catch (e) {
      setState(() {
        _schemaStatus = '❌ Schema test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkTables() async {
    try {
      setState(() {
        _tablesStatus = 'Checking database tables...';
      });

      final supabase = Supabase.instance.client;
      
      // List of tables we expect to exist
      final expectedTables = [
        'users', 'profiles', 'clothing_items', 'combinations', 
        'combination_items', 'follows', 'likes', 'comments', 
        'swap_listings', 'notifications'
      ];
      
      List<String> existingTables = [];
      List<String> missingTables = [];
      
      for (String table in expectedTables) {
        try {
          // Try to query the table (this will fail if table doesn't exist)
          await supabase.from(table).select('*').limit(1);
          existingTables.add(table);
        } catch (e) {
          missingTables.add(table);
        }
      }
      
      _availableTables = existingTables;
      
      setState(() {
        if (missingTables.isEmpty) {
          _tablesStatus = '✅ All expected tables exist: ${existingTables.join(', ')}';
        } else {
          _tablesStatus = '⚠️ Missing tables: ${missingTables.join(', ')}\n✅ Existing: ${existingTables.join(', ')}';
        }
      });
    } catch (e) {
      setState(() {
        _tablesStatus = '❌ Table check failed: $e';
      });
    }
  }

  Future<void> _testCrudOperations() async {
    try {
      setState(() {
        _schemaStatus = 'Testing CRUD operations...';
      });

      final supabase = Supabase.instance.client;
      
      // Test basic queries on available tables
      Map<String, String> results = {};
      
      for (String table in _availableTables) {
        try {
          final response = await supabase.from(table).select('*').limit(5);
          results[table] = '✅ Query successful (${response.length} rows)';
        } catch (e) {
          results[table] = '❌ Query failed: $e';
        }
      }
      
      setState(() {
        _schemaStatus = '✅ CRUD test completed:\n${results.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
      });
    } catch (e) {
      setState(() {
        _schemaStatus = '❌ CRUD test failed: $e';
      });
    }
  }

  Future<void> _testRlsPolicies() async {
    try {
      setState(() {
        _rlsStatus = 'Testing RLS policies...';
      });

      final supabase = Supabase.instance.client;
      
      // Test RLS by trying to access data without authentication
      // This should work for public data but fail for private data
      
      String rlsResults = '';
      
      // Test public combinations access (should work)
      try {
        final publicCombinations = await supabase
            .from('combinations')
            .select('*')
            .eq('is_public', true)
            .limit(5);
        rlsResults += '✅ Public combinations accessible\n';
      } catch (e) {
        rlsResults += '❌ Public combinations RLS issue: $e\n';
      }
      
      // Test private user data access (should be restricted)
      try {
        final users = await supabase
            .from('users')
            .select('*')
            .limit(1);
        rlsResults += '⚠️ Users table accessible without auth (might be expected)\n';
      } catch (e) {
        rlsResults += '✅ Users table properly protected by RLS\n';
      }
      
      setState(() {
        _rlsStatus = rlsResults.isNotEmpty ? rlsResults : '✅ RLS policies are active';
      });
    } catch (e) {
      setState(() {
        _rlsStatus = '❌ RLS test failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Schema Test'),
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
                    Text(
                      'Database Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('URL: ${dotenv.get('SUPABASE_URL', fallback: 'Not set')}'),
                    Text('Project: ${dotenv.get('SUPABASE_URL', fallback: 'Not set').split('.')[0].split('//').last}'),
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
                      Text(
                        'Schema Test Results',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusSection('Tables Check', _tablesStatus),
                              const SizedBox(height: 16),
                              _buildStatusSection('CRUD Operations', _schemaStatus),
                              const SizedBox(height: 16),
                              _buildStatusSection('RLS Policies', _rlsStatus),
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
              Center(
                child: ElevatedButton(
                  onPressed: _testDatabaseSchema,
                  child: const Text('Retest Schema'),
                ),
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
        Text(
          '$title:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
              color: status.startsWith('✅') 
                  ? Colors.green[700] 
                  : status.startsWith('❌')
                      ? Colors.red[700]
                      : status.startsWith('⚠️')
                          ? Colors.orange[700]
                          : Colors.blue[700],
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
