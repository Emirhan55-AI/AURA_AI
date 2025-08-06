import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
  
  // Supabase configuration - Load from environment or use defaults
  static String get supabaseUrl => 
    dotenv.env['SUPABASE_URL'] ?? 'https://your-project-id.supabase.co';
  
  static String get supabaseAnonKey => 
    dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key';
  
  static String get supabaseServiceRoleKey => 
    dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? 'your-service-role-key';
  
  // API endpoints
  static String get apiBaseUrl => 
    dotenv.env['API_BASE_URL'] ?? 'https://api.auraapp.com';
  
  static String get styleAssistantApiUrl => 
    dotenv.env['STYLE_ASSISTANT_API_URL'] ?? 'http://localhost:8000';
  
  // Development flags
  static bool get isDebugMode => 
    dotenv.env['DEBUG_MODE'] == 'true';
  
  // Storage paths
  static const String profileImagesBucket = 'profile_images';
  static const String clothingItemsImagesBucket = 'clothing_items';
  static const String socialPostsImagesBucket = 'social_posts';
  static const String swapListingsImagesBucket = 'swap_listings';
  
  // Cache configuration
  static const int defaultCacheValidityMinutes = 30;
  static const int maxCacheItems = 500;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Initialize environment variables
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // .env file is optional, continue with defaults
      print('Warning: .env file not found, using default values');
    }
  }
}
