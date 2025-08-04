import 'package:device_calendar/device_calendar.dart';

import '../models/calendar_event_model.dart';
import 'calendar_permission_service.dart';

/// Service for interacting with device calendar
/// Handles fetching events and calendar information from the device
class DeviceCalendarService {
  final CalendarPermissionService _permissionService;
  final DeviceCalendarPlugin _deviceCalendarPlugin;

  DeviceCalendarService({
    CalendarPermissionService? permissionService,
    DeviceCalendarPlugin? deviceCalendarPlugin,
  })  : _permissionService = permissionService ?? CalendarPermissionService(),
        _deviceCalendarPlugin = deviceCalendarPlugin ?? DeviceCalendarPlugin();

  /// Fetch calendar events within the specified date range
  Future<List<CalendarEventModel>> fetchEvents({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? calendarIds,
  }) async {
    // Check permission first
    final hasPermission = await _permissionService.hasCalendarPermission();
    if (!hasPermission) {
      throw CalendarPermissionException(
        'Calendar permission is required to fetch events',
      );
    }

    try {
      // Get available calendars if specific IDs aren't provided
      final calendarsToSearch = calendarIds ?? await _getAvailableCalendarIds();
      
      final List<CalendarEventModel> allEvents = [];
      
      // Set default date range if not provided
      final searchStartDate = startDate ?? DateTime.now();
      final searchEndDate = endDate ?? DateTime.now().add(const Duration(days: 30));

      // Fetch events from each calendar
      for (final calendarId in calendarsToSearch) {
        try {
          final retrieveEventsParams = RetrieveEventsParams(
            startDate: searchStartDate,
            endDate: searchEndDate,
          );

          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendarId,
            retrieveEventsParams,
          );

          if (eventsResult.isSuccess && eventsResult.data != null) {
            // Get calendar info for additional context
            final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
            final calendar = calendarResult.data?.firstWhere(
              (cal) => cal.id == calendarId,
              orElse: () => Calendar(id: calendarId, name: 'Unknown Calendar'),
            );

            // Convert device calendar events to our models
            final events = eventsResult.data!
                .map((event) => CalendarEventModel.fromDeviceCalendarEvent(
                      event,
                      calendar?.name ?? 'Unknown Calendar',
                      calendarColor: calendar?.color != null
                          ? '#${calendar!.color!.toRadixString(16).padLeft(8, '0')}'
                          : null,
                    ))
                .toList();

            allEvents.addAll(events);
          }
        } catch (e) {
          // Log error but continue with other calendars
          print('Error fetching events from calendar $calendarId: $e');
        }
      }

      // Sort events by start time
      allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      return allEvents;
    } catch (e) {
      throw CalendarServiceException(
        'Failed to fetch calendar events: ${e.toString()}',
      );
    }
  }

  /// Fetch events for a specific date
  Future<List<CalendarEventModel>> fetchEventsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return fetchEvents(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get available calendars on the device
  Future<List<CalendarInfoModel>> getAvailableCalendars() async {
    // Check permission first
    final hasPermission = await _permissionService.hasCalendarPermission();
    if (!hasPermission) {
      throw CalendarPermissionException(
        'Calendar permission is required to access calendars',
      );
    }

    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      
      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        return calendarsResult.data!
            .map((calendar) => CalendarInfoModel.fromDeviceCalendar(calendar))
            .toList();
      } else {
        throw CalendarServiceException(
          'Failed to retrieve calendars: ${calendarsResult.errors.join(", ")}',
        );
      }
    } catch (e) {
      throw CalendarServiceException(
        'Failed to get available calendars: ${e.toString()}',
      );
    }
  }

  /// Check if calendar permission is granted
  Future<bool> hasCalendarPermission() async {
    return await _permissionService.hasCalendarPermission();
  }

  /// Request calendar permission
  Future<bool> requestCalendarPermission() async {
    return await _permissionService.requestCalendarPermission();
  }

  /// Get detailed permission status
  Future<CalendarPermissionStatus> getPermissionStatus() async {
    return await _permissionService.getDetailedPermissionStatus();
  }

  /// Helper method to get available calendar IDs
  Future<List<String>> _getAvailableCalendarIds() async {
    try {
      final calendars = await getAvailableCalendars();
      return calendars.map((calendar) => calendar.id).toList();
    } catch (e) {
      // Return empty list if we can't get calendars
      return [];
    }
  }
}

/// Exception thrown when calendar permission is not granted
class CalendarPermissionException implements Exception {
  final String message;
  
  const CalendarPermissionException(this.message);
  
  @override
  String toString() => 'CalendarPermissionException: $message';
}

/// Exception thrown when calendar service encounters an error
class CalendarServiceException implements Exception {
  final String message;
  
  const CalendarServiceException(this.message);
  
  @override
  String toString() => 'CalendarServiceException: $message';
}
