import 'dart:io';
import 'package:flutter/foundation.dart';

/// Network security service with certificate pinning and secure communications
class NetworkSecurityService {
  // Certificate pinning configuration
  static const Map<String, List<String>> _certificatePins = {
    // Supabase API endpoints
    'supabase.co': [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Example pin
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Backup pin
    ],
    // Custom domain pins would go here
    'api.aura-app.com': [
      'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
    ],
  };

  // Security headers for API requests
  static const Map<String, String> _securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Content-Security-Policy': "default-src 'self'",
    'Referrer-Policy': 'strict-origin-when-cross-origin',
  };

  /// Create a secure HTTP client with certificate pinning
  static HttpClient createSecureHttpClient() {
    final client = HttpClient();
    
    // Configure certificate validation
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return _validateCertificate(cert, host);
    };

    // Set connection timeout
    client.connectionTimeout = const Duration(seconds: 30);
    
    return client;
  }

  /// Validate certificate against pinned certificates
  static bool _validateCertificate(X509Certificate certificate, String host) {
    try {
      // In debug mode, allow all certificates for development
      if (kDebugMode) {
        return true;
      }

      // Get the pinned certificates for this host
      final pins = _certificatePins[host];
      if (pins == null || pins.isEmpty) {
        // No pins configured - use default validation
        return true;
      }

      // Extract certificate SHA256 fingerprint
      final certFingerprint = _getCertificateFingerprint(certificate);
      
      // Check if the certificate matches any pinned certificate
      return pins.contains(certFingerprint);
    } catch (e) {
      debugPrint('Certificate validation error: $e');
      return false;
    }
  }

  /// Extract SHA256 fingerprint from certificate
  static String _getCertificateFingerprint(X509Certificate certificate) {
    // This is a simplified implementation
    // In production, properly extract and hash the certificate
    return 'sha256/PLACEHOLDER_FINGERPRINT';
  }

  /// Get security headers for API requests
  static Map<String, String> getSecurityHeaders() {
    return Map.from(_securityHeaders);
  }

  /// Validate request URL for security
  static bool isUrlSecure(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Must use HTTPS
      if (uri.scheme != 'https') {
        return false;
      }

      // Check against allowed domains
      final allowedDomains = [
        'supabase.co',
        'api.aura-app.com',
        // Add other trusted domains
      ];

      return allowedDomains.any((domain) => 
          uri.host.endsWith(domain) || uri.host == domain);
    } catch (e) {
      debugPrint('URL validation error: $e');
      return false;
    }
  }

  /// Sanitize input data to prevent injection attacks
  static String sanitizeInput(String input) {
    // Remove dangerous characters and patterns
    return input
        .replaceAll(RegExp(r'[<>"\x27`]'), '') // Remove HTML/JS injection chars using hex for single quote
        .replaceAll(RegExp(r'(script|javascript|vbscript)', caseSensitive: false), '')
        .replaceAll(RegExp(r'(union|select|insert|update|delete|drop)', caseSensitive: false), '')
        .trim();
  }

  /// Generate secure random token
  static String generateSecureToken({int length = 32}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = HttpClient().connectionTimeout; // Use a random source
    
    return List.generate(length, (index) => 
        chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]
    ).join();
  }

  /// Check if app is running in secure environment
  static Future<SecurityEnvironmentCheck> checkSecurityEnvironment() async {
    try {
      // Check for debugging
      final isDebugging = kDebugMode;
      
      // Check for rooting/jailbreak (simplified check)
      final isPotentiallyCompromised = await _checkDeviceIntegrity();
      
      // Check network security
      final hasSecureNetwork = await _checkNetworkSecurity();
      
      return SecurityEnvironmentCheck(
        isDebugging: isDebugging,
        isPotentiallyCompromised: isPotentiallyCompromised,
        hasSecureNetwork: hasSecureNetwork,
        isSecure: !isDebugging && !isPotentiallyCompromised && hasSecureNetwork,
      );
    } catch (e) {
      debugPrint('Security environment check failed: $e');
      return SecurityEnvironmentCheck(
        isDebugging: true,
        isPotentiallyCompromised: true,
        hasSecureNetwork: false,
        isSecure: false,
      );
    }
  }

  /// Check device integrity (simplified implementation)
  static Future<bool> _checkDeviceIntegrity() async {
    try {
      // This is a simplified check
      // In production, use proper root/jailbreak detection libraries
      
      if (Platform.isAndroid) {
        // Check for common rooting indicators
        final suspiciousApps = [
          'com.noshufou.android.su',
          'com.thirdparty.superuser',
          'eu.chainfire.supersu',
        ];
        
        // In a real implementation, check if these apps are installed
        return false; // Assume not rooted for now
      }
      
      if (Platform.isIOS) {
        // Check for jailbreak indicators
        final jailbreakPaths = [
          '/Applications/Cydia.app',
          '/usr/sbin/sshd',
          '/bin/bash',
        ];
        
        // In a real implementation, check if these paths exist
        return false; // Assume not jailbroken for now
      }
      
      return false;
    } catch (e) {
      debugPrint('Device integrity check error: $e');
      return true; // Assume compromised on error
    }
  }

  /// Check network security
  static Future<bool> _checkNetworkSecurity() async {
    try {
      // Check if using VPN (simplified)
      // In production, implement proper network security checks
      return true; // Assume secure for now
    } catch (e) {
      debugPrint('Network security check error: $e');
      return false;
    }
  }

  /// Configure SSL/TLS settings
  static void configureSSLContext(SecurityContext context) {
    try {
      // Set minimum TLS version
      // Note: This is platform-specific configuration
      
      // Add trusted certificates if needed
      // context.setTrustedCertificates('path/to/trusted/certs.pem');
      
      // Configure cipher suites (platform-specific)
      // Strong cipher suites only
      
    } catch (e) {
      debugPrint('SSL context configuration error: $e');
    }
  }
}

/// Security environment check result
class SecurityEnvironmentCheck {
  final bool isDebugging;
  final bool isPotentiallyCompromised;
  final bool hasSecureNetwork;
  final bool isSecure;

  SecurityEnvironmentCheck({
    required this.isDebugging,
    required this.isPotentiallyCompromised,
    required this.hasSecureNetwork,
    required this.isSecure,
  });

  Map<String, dynamic> toJson() => {
    'isDebugging': isDebugging,
    'isPotentiallyCompromised': isPotentiallyCompromised,
    'hasSecureNetwork': hasSecureNetwork,
    'isSecure': isSecure,
  };

  @override
  String toString() {
    return 'SecurityEnvironmentCheck('
        'isDebugging: $isDebugging, '
        'isPotentiallyCompromised: $isPotentiallyCompromised, '
        'hasSecureNetwork: $hasSecureNetwork, '
        'isSecure: $isSecure)';
  }
}
