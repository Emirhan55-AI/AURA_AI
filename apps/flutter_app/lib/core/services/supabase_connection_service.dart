import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Service for testing and validating Supabase connection
class SupabaseConnectionService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Test the connection to Supabase
  static Future<SupabaseConnectionResult> testConnection() async {
    try {
      // Test 1: Basic connection
      final response = await _client.from('clothing_categories').select('id').limit(1);
      
      // Test 2: Authentication capability
      final authTest = _client.auth.currentUser != null;
      
      // Test 3: Storage capability
      final storageTest = await _testStorageAccess();
      
      return SupabaseConnectionResult(
        isConnected: true,
        hasAuth: authTest,
        hasDatabase: response.isNotEmpty || response.isEmpty, // Both are valid
        hasStorage: storageTest,
        message: 'Connection successful',
        url: AppConstants.supabaseUrl,
      );
    } catch (e) {
      return SupabaseConnectionResult(
        isConnected: false,
        hasAuth: false,
        hasDatabase: false,
        hasStorage: false,
        message: 'Connection failed: ${e.toString()}',
        url: AppConstants.supabaseUrl,
        error: e.toString(),
      );
    }
  }

  /// Test storage access
  static Future<bool> _testStorageAccess() async {
    try {
      // Try to list buckets (this will fail gracefully if no access)
      await _client.storage.listBuckets();
      return true;
    } catch (e) {
      // Storage might not be accessible without auth, but that's okay
      return false;
    }
  }

  /// Get database schema info
  static Future<List<String>> getDatabaseTables() async {
    try {
      // This is a simple way to check if our main tables exist
      final tables = <String>[];
      
      // Test each main table
      final testTables = [
        'profiles',
        'clothing_categories', 
        'clothing_items',
        'outfits',
        'social_posts',
        'notifications',
        'messages'
      ];
      
      for (final table in testTables) {
        try {
          await _client.from(table).select('id').limit(1);
          tables.add(table);
        } catch (e) {
          // Table doesn't exist or no access
          print('Table $table not accessible: $e');
        }
      }
      
      return tables;
    } catch (e) {
      return [];
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get current user info
  static User? get currentUser => _client.auth.currentUser;

  /// Get connection status summary
  static Future<String> getConnectionSummary() async {
    final result = await testConnection();
    final tables = await getDatabaseTables();
    
    return '''
Supabase Connection Status:
- URL: ${result.url}
- Connected: ${result.isConnected ? '✅' : '❌'}
- Database: ${result.hasDatabase ? '✅' : '❌'}
- Authentication: ${result.hasAuth ? '✅' : '❌'}  
- Storage: ${result.hasStorage ? '✅' : '❌'}
- Available Tables: ${tables.isEmpty ? 'None' : tables.join(', ')}
- Message: ${result.message}
${result.error != null ? '- Error: ${result.error}' : ''}
''';
  }
}

/// Result class for connection testing
class SupabaseConnectionResult {
  final bool isConnected;
  final bool hasAuth;
  final bool hasDatabase;
  final bool hasStorage;
  final String message;
  final String url;
  final String? error;

  SupabaseConnectionResult({
    required this.isConnected,
    required this.hasAuth,
    required this.hasDatabase,
    required this.hasStorage,
    required this.message,
    required this.url,
    this.error,
  });

  @override
  String toString() {
    return 'SupabaseConnectionResult(connected: $isConnected, auth: $hasAuth, db: $hasDatabase, storage: $hasStorage)';
  }
}
