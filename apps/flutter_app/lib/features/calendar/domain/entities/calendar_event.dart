import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

/// Domain entity representing a calendar event
/// This is the clean domain representation used throughout the application
@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    /// Unique identifier for the event
    required String id,
    
    /// Event title/summary
    required String title,
    
    /// Event description (optional)
    String? description,
    
    /// Event start date and time
    required DateTime startTime,
    
    /// Event end date and time
    required DateTime endTime,
    
    /// Whether this is an all-day event
    @Default(false) bool isAllDay,
    
    /// Location of the event (optional)
    String? location,
    
    /// Calendar source name (e.g., "Personal", "Work")
    String? calendarName,
    
    /// Calendar color (hex string)
    String? calendarColor,
    
    /// Event organizer email or name
    String? organizer,
    
    /// List of attendee emails
    @Default([]) List<String> attendees,
    
    /// Event recurrence rule (optional)
    String? recurrenceRule,
    
    /// Linked outfit ID for styling integration
    /// TODO: This will be used for outfit suggestions and linking
    String? linkedOutfitId,
    
    /// Additional metadata for AI styling suggestions
    /// TODO: This can include parsed event type, dress code hints, etc.
    @Default({}) Map<String, dynamic> metadata,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
}

/// Extension for calendar event utility methods
extension CalendarEventExtension on CalendarEvent {
  /// Check if the event is happening today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(startTime.year, startTime.month, startTime.day);
    return eventDate == today;
  }

  /// Check if the event is upcoming (in the future)
  bool get isUpcoming {
    return startTime.isAfter(DateTime.now());
  }

  /// Check if the event is currently happening
  bool get isHappening {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Get event duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60.0;
  }

  /// Get a formatted time range string
  String get timeRange {
    if (isAllDay) {
      return 'All Day';
    }
    
    final startFormatted = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormatted = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    
    return '$startFormatted - $endFormatted';
  }

  /// Check if this event has potential for outfit suggestions
  /// Based on event metadata and duration
  bool get isSuitableForOutfitSuggestion {
    // Events longer than 30 minutes and not all-day are good candidates
    return durationInHours >= 0.5 && !isAllDay && isUpcoming;
  }

  /// Extract potential event type from title for AI suggestions
  /// TODO: This can be enhanced with NLP or pattern matching
  String? get suggestedEventType {
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('meeting') || titleLower.contains('work')) {
      return 'business';
    } else if (titleLower.contains('dinner') || titleLower.contains('restaurant')) {
      return 'dinner';
    } else if (titleLower.contains('party') || titleLower.contains('celebration')) {
      return 'party';
    } else if (titleLower.contains('workout') || titleLower.contains('gym')) {
      return 'workout';
    } else if (titleLower.contains('date') || titleLower.contains('romantic')) {
      return 'date';
    } else if (titleLower.contains('interview') || titleLower.contains('formal')) {
      return 'formal';
    }
    
    return 'casual'; // Default to casual
  }
}
