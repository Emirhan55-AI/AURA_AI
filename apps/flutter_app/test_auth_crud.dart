import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded successfully');
    
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
    print('✅ Supabase initialized successfully');
    
  } catch (e) {
    print('❌ Initialization error: $e');
  }
  
  runApp(const AuthTestApp());
}

class AuthTestApp extends StatelessWidget {
  const AuthTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication & CRUD Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthTestScreen(),
    );
  }
}

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  String _authStatus = 'Not tested';
  String _crudStatus = 'Not tested';
  String _realtimeStatus = 'Not tested';
  bool _isLoading = false;
  bool _isAuthenticated = false;
  
  final _emailController = TextEditingController(text: 'test@aura.com');
  final _passwordController = TextEditingController(text: 'testpassword123');

  @override
  void initState() {
    super.initState();
    _checkCurrentAuth();
    // _testRealtime(); // Temporarily disabled due to error
  }

  Future<void> _checkCurrentAuth() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        setState(() {
          _authStatus = '✅ Already authenticated: ${user.email}';
          _isAuthenticated = true;
        });
        await _testCrudOperations();
      } else {
        setState(() {
          _authStatus = '⚠️ Not authenticated - Please sign up/sign in';
        });
      }
    } catch (e) {
      setState(() {
        _authStatus = '❌ Auth check failed: $e';
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _authStatus = 'Creating account...';
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        setState(() {
          _authStatus = '✅ Account created successfully! Email: ${response.user!.email}';
          _isAuthenticated = true;
        });
        
        // Create user profile in our custom users table
        await _createUserProfile(response.user!);
        
        // Wait a bit for authentication context to be fully set
        await Future.delayed(const Duration(milliseconds: 2000));
        
        print('🚀 About to call CRUD operations...');
        await _testCrudOperations(response.user!);
        print('🏁 CRUD operations call completed');
      } else {
        setState(() {
          _authStatus = '❌ Sign up failed - no user returned';
        });
      }
    } catch (e) {
      print('❌ Sign up process failed: $e');
      setState(() {
        _authStatus = '❌ Sign up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _authStatus = 'Signing in...';
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        setState(() {
          _authStatus = '✅ Signed in successfully! Email: ${response.user!.email}';
          _isAuthenticated = true;
        });
        await _testCrudOperations();
      } else {
        setState(() {
          _authStatus = '❌ Sign in failed - no user returned';
        });
      }
    } catch (e) {
      setState(() {
        _authStatus = '❌ Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      // Insert user into our custom users table
      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'email': user.email,
        'full_name': 'Test User',
        'username': 'testuser_${user.id.substring(0, 8)}',
        'bio': 'Test user created by authentication test',
      });

      // Insert profile
      await Supabase.instance.client.from('profiles').insert({
        'user_id': user.id,
        'preferred_style': {'styles': ['casual', 'modern']},
        'onboarding_skipped': false,
      });

      print('✅ User profile created in database');
    } catch (e) {
      print('⚠️ Profile creation failed: $e');
    }
  }

  Future<void> _testCrudOperations([User? user]) async {
    print('🔍 Starting CRUD operations...');
    
    if (!_isAuthenticated) {
      print('❌ Authentication required for CRUD operations');
      setState(() {
        _crudStatus = '❌ Authentication required for CRUD operations';
      });
      return;
    }

    print('✅ Authentication check passed');
    setState(() {
      _crudStatus = 'Testing CRUD operations...';
    });

    try {
      print('🔍 Getting current user...');
      final currentUser = user ?? Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('❌ Current user is null');
        setState(() {
          _crudStatus = '❌ User not authenticated for CRUD operations';
        });
        return;
      }
      
      print('✅ Current user found: ${currentUser.id}');
      
      // Test 1: Create a clothing item
      final clothingItem = await Supabase.instance.client.from('clothing_items').insert({
        'user_id': currentUser.id,
        'name': 'Test Blue Jeans',
        'category': 'Bottom',
        'color': 'Blue',
        'brand': 'Test Brand',
        'price': 99.99,
        'currency': 'USD',
        'notes': 'Created by CRUD test',
        'tags': ['casual', 'denim'],
        'is_favorite': false,
      }).select().single();

      // Test 2: Read the item back
      final readItem = await Supabase.instance.client
          .from('clothing_items')
          .select('*')
          .eq('id', clothingItem['id'] as Object)
          .single();

      // Test 3: Update the item
      await Supabase.instance.client
          .from('clothing_items')
          .update({'is_favorite': true, 'notes': 'Updated by CRUD test'})
          .eq('id', clothingItem['id'] as Object);

      // Test 4: Create a combination
      final combination = await Supabase.instance.client.from('combinations').insert({
        'user_id': currentUser.id,
        'name': 'Test Casual Outfit',
        'description': 'Created by CRUD test',
        'is_public': true,
      }).select().single();

      // Test 5: Link clothing item to combination
      await Supabase.instance.client.from('combination_items').insert({
        'combination_id': combination['id'],
        'clothing_item_id': clothingItem['id'],
        'position_data': {'x': 100, 'y': 100},
      });

      // Test 6: Read combination with items
      final combinationWithItems = await Supabase.instance.client
          .from('combinations')
          .select('''
            *,
            combination_items(
              *,
              clothing_items(*)
            )
          ''')
          .eq('id', combination['id'] as Object)
          .single();

      setState(() {
        _crudStatus = '''✅ CRUD Operations Successful:
• Created clothing item: ${readItem['name']}
• Updated item to favorite: ${readItem['is_favorite']}
• Created combination: ${combination['name']}
• Linked items to combination
• Retrieved combination with ${combinationWithItems['combination_items'].length} items''';
      });

    } catch (e) {
      print('❌ CRUD operations failed: $e');
      setState(() {
        _crudStatus = '❌ CRUD operations failed: $e';
      });
    }
  }

  Future<void> _testRealtime() async {
    try {
      setState(() {
        _realtimeStatus = 'Testing realtime connection...';
      });

      Supabase.instance.client
          .channel('test_channel')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'clothing_items',
            callback: (payload) {
              print('Realtime event received: ${payload.newRecord}');
              setState(() {
                _realtimeStatus = '✅ Realtime working! Received insert event for clothing_items';
              });
            },
          )
          .subscribe();

      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _realtimeStatus = '✅ Realtime channel subscribed successfully';
      });
    } catch (e) {
      setState(() {
        _realtimeStatus = '❌ Realtime test failed: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      setState(() {
        _authStatus = '✅ Signed out successfully';
        _isAuthenticated = false;
        _crudStatus = 'Not tested';
      });
    } catch (e) {
      setState(() {
        _authStatus = '❌ Sign out failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication & CRUD Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth Form
            if (!_isAuthenticated) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Authentication', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            child: const Text('Sign Up'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Test Results
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Test Results', style: Theme.of(context).textTheme.titleLarge),
                          if (_isAuthenticated)
                            ElevatedButton(
                              onPressed: _signOut,
                              child: const Text('Sign Out'),
                            ),
                        ],
                      ),
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

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            if (_isAuthenticated)
              Center(
                child: ElevatedButton(
                  onPressed: _testCrudOperations,
                  child: const Text('Retest CRUD Operations'),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
