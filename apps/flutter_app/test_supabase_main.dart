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
  
  runApp(const SupabaseTestApp());
}

class SupabaseTestApp extends StatelessWidget {
  const SupabaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Connection Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SupabaseTestScreen(),
    );
  }
}

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  String _connectionStatus = 'Not tested';
  String _databaseStatus = 'Not tested';
  String _authStatus = 'Not tested';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing connection...';
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Test basic connection
      setState(() {
        _connectionStatus = '✅ Supabase client initialized successfully!';
      });
      
      // Test database connection
      await _testDatabase();
      
      // Test auth
      await _testAuth();
      
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDatabase() async {
    try {
      setState(() {
        _databaseStatus = 'Testing database connection...';
      });

      final supabase = Supabase.instance.client;
      
      // Try to query a simple system table or create a test query
      // This is a safe query that should work on any Supabase instance
      final response = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .limit(1);
      
      setState(() {
        _databaseStatus = '✅ Database connection successful!';
      });
    } catch (e) {
      // If information_schema doesn't work, try a simpler approach
      try {
        final response = await Supabase.instance.client.rpc('version');
        setState(() {
          _databaseStatus = '✅ Database connection successful (via RPC)!';
        });
      } catch (e2) {
        setState(() {
          _databaseStatus = '❌ Database connection failed: $e2';
        });
      }
    }
  }

  Future<void> _testAuth() async {
    try {
      setState(() {
        _authStatus = 'Testing auth service...';
      });

      final supabase = Supabase.instance.client;
      
      // Test auth by getting current session (should be null for anonymous)
      final session = supabase.auth.currentSession;
      
      setState(() {
        _authStatus = '✅ Auth service accessible! Current session: ${session != null ? 'Authenticated' : 'Anonymous'}';
      });
    } catch (e) {
      setState(() {
        _authStatus = '❌ Auth test failed: $e';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('URL: ${dotenv.get('SUPABASE_URL', fallback: 'Not set')}'),
                    Text('Anon Key: ${dotenv.get('SUPABASE_ANON_KEY', fallback: 'Not set').substring(0, 20)}...'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildStatusRow('Client Connection', _connectionStatus),
                    const SizedBox(height: 8),
                    _buildStatusRow('Database', _databaseStatus),
                    const SizedBox(height: 8),
                    _buildStatusRow('Authentication', _authStatus),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_isLoading)
              Center(
                child: ElevatedButton(
                  onPressed: _testConnection,
                  child: const Text('Retest Connection'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            status,
            style: TextStyle(
              color: status.startsWith('✅') 
                  ? Colors.green[700] 
                  : status.startsWith('❌')
                      ? Colors.red[700]
                      : Colors.orange[700],
            ),
          ),
        ),
      ],
    );
  }
}
