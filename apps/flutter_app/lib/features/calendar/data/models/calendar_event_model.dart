import 'package:device_calendar/device_calendar.dart' as device_cal;

import '../../domain/entities/calendar_event.dart';

/// Data model for calendar events from device_calendar package
/// This handles the mapping between external library and our domain model
class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final String? calendarName;
  final String? calendarColor;
  final String? organizer;
  final List<String> attendees;
  final String? recurrenceRule;

  const CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.location,
    this.calendarName,
    this.calendarColor,
    this.organizer,
    this.attendees = const [],
    this.recurrenceRule,
  });

  /// Convert from device_calendar Event to our model
  factory CalendarEventModel.fromDeviceCalendarEvent(
    device_cal.Event event,
    String calendarName, {
    String? calendarColor,
  }) {
    return CalendarEventModel(
      id: event.eventId ?? '',
      title: event.title ?? 'Untitled Event',
      description: event.description,
      startTime: event.start ?? DateTime.now(),
      endTime: event.end ?? DateTime.now().add(const Duration(hours: 1)),
      isAllDay: event.allDay ?? false,
      location: event.location,
      calendarName: calendarName,
      calendarColor: calendarColor,
      organizer: event.organizer?.name ?? event.organizer?.emailAddress,
      attendees: event.attendees
              ?.map((attendee) => attendee.emailAddress ?? attendee.name ?? '')
              .where((email) => email.isNotEmpty)
              .toList() ??
          [],
      recurrenceRule: event.recurrenceRule?.toString(),
    );
  }

  /// Convert to domain entity
  CalendarEvent toDomainEntity() {
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      location: location,
      calendarName: calendarName,
      calendarColor: calendarColor,
      organizer: organizer,
      attendees: attendees,
      recurrenceRule: recurrenceRule,
      // These will be added when outfit linking is implemented
      linkedOutfitId: null,
      metadata: {},
    );
  }

  /// Convert from domain entity to model
  factory CalendarEventModel.fromDomainEntity(CalendarEvent event) {
    return CalendarEventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      location: event.location,
      calendarName: event.calendarName,
      calendarColor: event.calendarColor,
      organizer: event.organizer,
      attendees: event.attendees,
      recurrenceRule: event.recurrenceRule,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CalendarEventModel{id: $id, title: $title, startTime: $startTime}';
  }
}

/// Model for calendar information
class CalendarInfoModel {
  final String id;
  final String name;
  final String? color;
  final bool isReadOnly;
  final bool isDefault;

  const CalendarInfoModel({
    required this.id,
    required this.name,
    this.color,
    this.isReadOnly = false,
    this.isDefault = false,
  });

  /// Convert from device_calendar Calendar to our model
  factory CalendarInfoModel.fromDeviceCalendar(device_cal.Calendar calendar) {
    return CalendarInfoModel(
      id: calendar.id ?? '',
      name: calendar.name ?? 'Unnamed Calendar',
      color: calendar.color != null 
          ? '#${calendar.color!.value.toRadixString(16).padLeft(8, '0')}'
          : null,
      isReadOnly: calendar.readOnly ?? false,
      isDefault: calendar.isDefault ?? false,
    );
  }

  /// Convert to domain CalendarInfo
  device_cal.CalendarInfo toDomainInfo() {
    return device_cal.CalendarInfo(
      id: id,
      name: name,
      color: color,
      isReadOnly: isReadOnly,
      isDefault: isDefault,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarInfoModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CalendarInfoModel{id: $id, name: $name, color: $color}';
  }
}
