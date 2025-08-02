import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_service.g.dart';

/// Cache service for managing application data persistence
/// Provides type-safe caching with automatic expiration and cleanup
abstract class CacheService {
  /// Store a value in cache with optional expiration
  Future<bool> set<T>(String key, T value, {Duration? expiration});
  
  /// Retrieve a value from cache
  Future<T?> get<T>(String key);
  
  /// Remove a specific key from cache
  Future<bool> remove(String key);
  
  /// Clear all cache data
  Future<bool> clear();
  
  /// Check if a key exists and is not expired
  Future<bool> exists(String key);
  
  /// Get cache size information
  Future<CacheInfo> getInfo();
}

/// Cache information model
class CacheInfo {
  const CacheInfo({
    required this.totalKeys,
    required this.expiredKeys,
    required this.approximateSize,
  });

  final int totalKeys;
  final int expiredKeys;
  final int approximateSize; // in bytes

  @override
  String toString() =>
      'CacheInfo(total: $totalKeys, expired: $expiredKeys, size: ${approximateSize}B)';
}

/// Shared preferences based cache implementation
class SharedPreferencesCacheService implements CacheService {
  SharedPreferencesCacheService(this._prefs);
  
  final SharedPreferences _prefs;
  
  static const String _expirationPrefix = '__expiration__';
  static const String _cachePrefix = '__cache__';
  
  @override
  Future<bool> set<T>(String key, T value, {Duration? expiration}) async {
    try {
      final String cacheKey = _getCacheKey(key);
      final String jsonValue = jsonEncode(value);
      
      // Store the value
      final bool success = await _prefs.setString(cacheKey, jsonValue);
      
      // Store expiration if provided
      if (expiration != null && success) {
        final int expirationTime = DateTime.now()
            .add(expiration)
            .millisecondsSinceEpoch;
        await _prefs.setInt(_getExpirationKey(key), expirationTime);
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<T?> get<T>(String key) async {
    try {
      // Check if expired
      if (await _isExpired(key)) {
        await remove(key);
        return null;
      }
      
      final String cacheKey = _getCacheKey(key);
      final String? jsonValue = _prefs.getString(cacheKey);
      
      if (jsonValue == null) return null;
      
      return jsonDecode(jsonValue) as T;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> remove(String key) async {
    try {
      final String cacheKey = _getCacheKey(key);
      final String expirationKey = _getExpirationKey(key);
      
      final bool removedCache = await _prefs.remove(cacheKey);
      final bool removedExpiration = await _prefs.remove(expirationKey);
      
      return removedCache || removedExpiration;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> clear() async {
    try {
      final Set<String> keys = _prefs.getKeys();
      final List<String> cacheKeys = keys
          .where((String key) =>
              key.startsWith(_cachePrefix) ||
              key.startsWith(_expirationPrefix))
          .toList();
      
      for (final String key in cacheKeys) {
        await _prefs.remove(key);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> exists(String key) async {
    if (await _isExpired(key)) {
      await remove(key);
      return false;
    }
    
    final String cacheKey = _getCacheKey(key);
    return _prefs.containsKey(cacheKey);
  }
  
  @override
  Future<CacheInfo> getInfo() async {
    final Set<String> allKeys = _prefs.getKeys();
    final List<String> cacheKeys = allKeys
        .where((String key) => key.startsWith(_cachePrefix))
        .toList();
    
    int expiredCount = 0;
    int totalSize = 0;
    
    for (final String cacheKey in cacheKeys) {
      final String originalKey = cacheKey.substring(_cachePrefix.length);
      
      if (await _isExpired(originalKey)) {
        expiredCount++;
      }
      
      final String? value = _prefs.getString(cacheKey);
      if (value != null) {
        totalSize += value.length * 2; // Approximate UTF-16 size
      }
    }
    
    return CacheInfo(
      totalKeys: cacheKeys.length,
      expiredKeys: expiredCount,
      approximateSize: totalSize,
    );
  }
  
  Future<bool> _isExpired(String key) async {
    final String expirationKey = _getExpirationKey(key);
    final int? expirationTime = _prefs.getInt(expirationKey);
    
    if (expirationTime == null) return false;
    
    return DateTime.now().millisecondsSinceEpoch > expirationTime;
  }
  
  String _getCacheKey(String key) => '$_cachePrefix$key';
  String _getExpirationKey(String key) => '$_expirationPrefix$key';
}

/// Cache service provider
@Riverpod(keepAlive: true)
Future<CacheService> cacheService(CacheServiceRef ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return SharedPreferencesCacheService(prefs);
}

/// Cache management utility provider
@riverpod
class CacheManager extends _$CacheManager {
  @override
  FutureOr<void> build() {
    // Initialize cache manager
  }
  
  /// Perform cache cleanup - remove expired entries
  Future<void> cleanup() async {
    final CacheService cache = await ref.read(cacheServiceProvider.future);
    final CacheInfo info = await cache.getInfo();
    
    // Only cleanup if we have expired entries
    if (info.expiredKeys > 0) {
      // Get all keys and check for expired ones
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Set<String> allKeys = prefs.getKeys();
      
      for (final String key in allKeys) {
        if (key.startsWith('__cache__')) {
          final String originalKey = key.substring('__cache__'.length);
          if (!(await cache.exists(originalKey))) {
            // This will remove expired entries
          }
        }
      }
    }
  }
  
  /// Get cache statistics
  Future<CacheInfo> getStats() async {
    final CacheService cache = await ref.read(cacheServiceProvider.future);
    return cache.getInfo();
  }
  
  /// Clear all cache data
  Future<bool> clearAll() async {
    final CacheService cache = await ref.read(cacheServiceProvider.future);
    return cache.clear();
  }
}

/// Typed cache keys for type safety
class CacheKeys {
  static const String userPreferences = 'user_preferences';
  static const String wardrobeItems = 'wardrobe_items';
  static const String outfitRecommendations = 'outfit_recommendations';
  static const String weatherData = 'weather_data';
  static const String userProfile = 'user_profile';
  static const String appSettings = 'app_settings';
  static const String offlineData = 'offline_data';
  
  // Cache expiration durations
  static const Duration shortTerm = Duration(minutes: 15);
  static const Duration mediumTerm = Duration(hours: 1);
  static const Duration longTerm = Duration(days: 1);
  static const Duration persistent = Duration(days: 30);
}
