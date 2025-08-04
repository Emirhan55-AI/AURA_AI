import 'package:permission_handler/permission_handler.dart';

/// Service for handling calendar permissions
/// Manages requesting and checking calendar access permissions
class CalendarPermissionService {
  /// Check if calendar permission is currently granted
  Future<bool> hasCalendarPermission() async {
    try {
      final status = await Permission.calendar.status;
      return status.isGranted;
    } catch (e) {
      // If there's an error checking permission, assume it's not granted
      return false;
    }
  }

  /// Request calendar permission from the user
  /// Returns true if permission was granted, false otherwise
  Future<bool> requestCalendarPermission() async {
    try {
      final status = await Permission.calendar.request();
      return status.isGranted;
    } catch (e) {
      // If there's an error requesting permission, return false
      return false;
    }
  }

  /// Check if permission was permanently denied
  /// This is useful for showing settings redirect dialog
  Future<bool> isCalendarPermissionPermanentlyDenied() async {
    try {
      final status = await Permission.calendar.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings for manual permission management
  /// Returns true if settings were opened successfully
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// Get detailed permission status information
  Future<CalendarPermissionStatus> getDetailedPermissionStatus() async {
    try {
      final status = await Permission.calendar.status;
      
      if (status.isGranted) {
        return CalendarPermissionStatus.granted;
      } else if (status.isDenied) {
        return CalendarPermissionStatus.denied;
      } else if (status.isPermanentlyDenied) {
        return CalendarPermissionStatus.permanentlyDenied;
      } else if (status.isRestricted) {
        return CalendarPermissionStatus.restricted;
      } else {
        return CalendarPermissionStatus.unknown;
      }
    } catch (e) {
      return CalendarPermissionStatus.unknown;
    }
  }
}

/// Enum representing different calendar permission states
enum CalendarPermissionStatus {
  /// Permission is granted
  granted,
  
  /// Permission is denied but can be requested again
  denied,
  
  /// Permission is permanently denied, user must go to settings
  permanentlyDenied,
  
  /// Permission is restricted (e.g., parental controls)
  restricted,
  
  /// Permission status is unknown or couldn't be determined
  unknown,
}

/// Extension for calendar permission status utility methods
extension CalendarPermissionStatusExtension on CalendarPermissionStatus {
  /// Check if permission allows calendar access
  bool get allowsAccess => this == CalendarPermissionStatus.granted;
  
  /// Check if permission can be requested
  bool get canRequest => this == CalendarPermissionStatus.denied;
  
  /// Check if user should be redirected to settings
  bool get shouldOpenSettings => this == CalendarPermissionStatus.permanentlyDenied;
  
  /// Get user-friendly message for this permission status
  String get userMessage {
    switch (this) {
      case CalendarPermissionStatus.granted:
        return 'Calendar access is granted.';
      case CalendarPermissionStatus.denied:
        return 'Calendar access is needed to show your events.';
      case CalendarPermissionStatus.permanentlyDenied:
        return 'Calendar access was permanently denied. Please enable it in Settings.';
      case CalendarPermissionStatus.restricted:
        return 'Calendar access is restricted on this device.';
      case CalendarPermissionStatus.unknown:
        return 'Unable to determine calendar permission status.';
    }
  }
  
  /// Get user-friendly title for this permission status
  String get userTitle {
    switch (this) {
      case CalendarPermissionStatus.granted:
        return 'Access Granted';
      case CalendarPermissionStatus.denied:
        return 'Permission Needed';
      case CalendarPermissionStatus.permanentlyDenied:
        return 'Permission Denied';
      case CalendarPermissionStatus.restricted:
        return 'Access Restricted';
      case CalendarPermissionStatus.unknown:
        return 'Permission Unknown';
    }
  }
}
