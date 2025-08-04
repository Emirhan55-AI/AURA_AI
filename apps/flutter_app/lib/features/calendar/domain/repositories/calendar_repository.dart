import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/calendar_event.dart';

/// Repository interface for calendar data operations
/// Defines the contract for calendar data access following Clean Architecture principles
abstract class CalendarRepository {
  /// Fetches calendar events within the specified date range
  /// 
  /// Parameters:
  /// - [startDate]: Start date for the event range (optional, defaults to now)
  /// - [endDate]: End date for the event range (optional, defaults to 30 days from now)
  /// - [calendarIds]: Specific calendar IDs to fetch from (optional, fetches from all if null)
  /// 
  /// Returns: Either a Failure or a List of CalendarEvent entities
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? calendarIds,
  });

  /// Fetches events for a specific date
  /// 
  /// Parameters:
  /// - [date]: The specific date to fetch events for
  /// 
  /// Returns: Either a Failure or a List of CalendarEvent entities
  Future<Either<Failure, List<CalendarEvent>>> getEventsForDate(DateTime date);

  /// Checks if calendar permissions are granted
  /// 
  /// Returns: Either a Failure or a boolean indicating permission status
  Future<Either<Failure, bool>> hasCalendarPermission();

  /// Requests calendar permissions from the user
  /// 
  /// Returns: Either a Failure or a boolean indicating if permission was granted
  Future<Either<Failure, bool>> requestCalendarPermission();

  /// Gets available calendars on the device
  /// 
  /// Returns: Either a Failure or a List of calendar information
  Future<Either<Failure, List<CalendarInfo>>> getAvailableCalendars();

  /// Updates an event with linked outfit information
  /// TODO: This will be used for outfit linking functionality
  /// 
  /// Parameters:
  /// - [eventId]: The event ID to update
  /// - [outfitId]: The outfit ID to link (null to unlink)
  /// 
  /// Returns: Either a Failure or the updated CalendarEvent
  Future<Either<Failure, CalendarEvent>> linkOutfitToEvent(
    String eventId,
    String? outfitId,
  );
}

/// Calendar information data structure
class CalendarInfo {
  final String id;
  final String name;
  final String? color;
  final bool isReadOnly;
  final bool isDefault;

  const CalendarInfo({
    required this.id,
    required this.name,
    this.color,
    this.isReadOnly = false,
    this.isDefault = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'CalendarInfo{id: $id, name: $name, color: $color}';
}
