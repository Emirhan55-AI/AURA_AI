/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
  
  // Supabase configuration
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
  
  // API endpoints
  static const String apiBaseUrl = 'https://api.auraapp.com';
  static const String styleAssistantApiUrl = 'http://localhost:8000';
  
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
}
