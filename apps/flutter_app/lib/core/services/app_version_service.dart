import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version_service.g.dart';

/// Service for managing app version information and update checks
/// Provides current app version, build number, and update detection
class AppVersionService {
  /// Get current app version information
  Future<AppVersionInfo> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    return AppVersionInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
    );
  }

  /// Check if app needs update (placeholder for future implementation)
  /// This will be connected to app store/play store APIs
  Future<bool> needsUpdate() async {
    // TODO: Implement actual version checking logic
    // This could check against a remote endpoint or app store APIs
    return false;
  }

  /// Get available update information (placeholder for future implementation)
  Future<UpdateInfo?> getAvailableUpdate() async {
    // TODO: Implement actual update checking logic
    // This would fetch update information from app store or remote endpoint
    return null;
  }

  /// Format version string for display
  String formatVersionString(AppVersionInfo versionInfo) {
    return '${versionInfo.version} (${versionInfo.buildNumber})';
  }

  /// Compare two version strings
  /// Returns: 
  /// - negative if version1 < version2
  /// - zero if version1 == version2  
  /// - positive if version1 > version2
  int compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    final maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
    
    for (int i = 0; i < maxLength; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;
      
      if (v1Part != v2Part) {
        return v1Part - v2Part;
      }
    }
    
    return 0;
  }
}

/// App version information model
class AppVersionInfo {
  final String version;
  final String buildNumber;
  final String appName;
  final String packageName;

  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
    required this.appName,
    required this.packageName,
  });

  @override
  String toString() {
    return 'AppVersionInfo(version: $version, buildNumber: $buildNumber, appName: $appName, packageName: $packageName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppVersionInfo &&
      other.version == version &&
      other.buildNumber == buildNumber &&
      other.appName == appName &&
      other.packageName == packageName;
  }

  @override
  int get hashCode {
    return version.hashCode ^
      buildNumber.hashCode ^
      appName.hashCode ^
      packageName.hashCode;
  }
}

/// Update information model
class UpdateInfo {
  final String version;
  final String description;
  final bool isRequired;
  final String downloadUrl;

  const UpdateInfo({
    required this.version,
    required this.description,
    required this.isRequired,
    required this.downloadUrl,
  });

  @override
  String toString() {
    return 'UpdateInfo(version: $version, description: $description, isRequired: $isRequired, downloadUrl: $downloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UpdateInfo &&
      other.version == version &&
      other.description == description &&
      other.isRequired == isRequired &&
      other.downloadUrl == downloadUrl;
  }

  @override
  int get hashCode {
    return version.hashCode ^
      description.hashCode ^
      isRequired.hashCode ^
      downloadUrl.hashCode;
  }
}

/// Provider for AppVersionService instance
@riverpod
AppVersionService appVersionService(AppVersionServiceRef ref) {
  return AppVersionService();
}

/// Provider for current app version info
@riverpod
Future<AppVersionInfo> currentAppVersion(CurrentAppVersionRef ref) async {
  final service = ref.read(appVersionServiceProvider);
  return service.getCurrentVersion();
}

/// Provider for update check
@riverpod
Future<bool> appNeedsUpdate(AppNeedsUpdateRef ref) async {
  final service = ref.read(appVersionServiceProvider);
  return service.needsUpdate();
}

/// Provider for available update information
@riverpod
Future<UpdateInfo?> availableUpdate(AvailableUpdateRef ref) async {
  final service = ref.read(appVersionServiceProvider);
  return service.getAvailableUpdate();
}
