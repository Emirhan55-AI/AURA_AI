import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

/// Use case for fetching calendar events
/// Handles the business logic for retrieving events from the calendar
class GetCalendarEventsUseCase {
  final CalendarRepository _repository;

  const GetCalendarEventsUseCase(this._repository);

  /// Execute the use case to get calendar events
  /// 
  /// Parameters:
  /// - [params]: Parameters for fetching events
  /// 
  /// Returns: Either a Failure or a List of CalendarEvent entities
  Future<Either<Failure, List<CalendarEvent>>> call(
    GetCalendarEventsParams params,
  ) async {
    // First check if we have calendar permission
    final permissionResult = await _repository.hasCalendarPermission();
    
    if (permissionResult.isLeft()) {
      return permissionResult.fold(
        (failure) => Left(failure),
        (_) => const Left(UnknownFailure()),
      );
    }

    final hasPermission = permissionResult.fold(
      (_) => false,
      (granted) => granted,
    );

    if (!hasPermission) {
      return const Left(PermissionFailure(
        message: 'Calendar permission is required to fetch events.',
        code: 'CALENDAR_PERMISSION_DENIED',
      ));
    }

    // Fetch events with the provided parameters
    return await _repository.getEvents(
      startDate: params.startDate,
      endDate: params.endDate,
      calendarIds: params.calendarIds,
    );
  }
}

/// Use case for getting events for a specific date
class GetEventsForDateUseCase {
  final CalendarRepository _repository;

  const GetEventsForDateUseCase(this._repository);

  /// Execute the use case to get events for a specific date
  Future<Either<Failure, List<CalendarEvent>>> call(DateTime date) async {
    // Check permission first
    final permissionResult = await _repository.hasCalendarPermission();
    
    if (permissionResult.isLeft()) {
      return permissionResult.fold(
        (failure) => Left(failure),
        (_) => const Left(UnknownFailure()),
      );
    }

    final hasPermission = permissionResult.fold(
      (_) => false,
      (granted) => granted,
    );

    if (!hasPermission) {
      return const Left(PermissionFailure(
        message: 'Calendar permission is required to fetch events.',
        code: 'CALENDAR_PERMISSION_DENIED',
      ));
    }

    return await _repository.getEventsForDate(date);
  }
}

/// Use case for requesting calendar permission
class RequestCalendarPermissionUseCase {
  final CalendarRepository _repository;

  const RequestCalendarPermissionUseCase(this._repository);

  /// Execute the use case to request calendar permission
  Future<Either<Failure, bool>> call() async {
    return await _repository.requestCalendarPermission();
  }
}

/// Use case for getting available calendars
class GetAvailableCalendarsUseCase {
  final CalendarRepository _repository;

  const GetAvailableCalendarsUseCase(this._repository);

  /// Execute the use case to get available calendars
  Future<Either<Failure, List<CalendarInfo>>> call() async {
    // Check permission first
    final permissionResult = await _repository.hasCalendarPermission();
    
    if (permissionResult.isLeft()) {
      return permissionResult.fold(
        (failure) => Left(failure),
        (_) => const Left(UnknownFailure()),
      );
    }

    final hasPermission = permissionResult.fold(
      (_) => false,
      (granted) => granted,
    );

    if (!hasPermission) {
      return const Left(PermissionFailure(
        message: 'Calendar permission is required to access calendars.',
        code: 'CALENDAR_PERMISSION_DENIED',
      ));
    }

    return await _repository.getAvailableCalendars();
  }
}

/// Parameters for getting calendar events
class GetCalendarEventsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? calendarIds;

  const GetCalendarEventsParams({
    this.startDate,
    this.endDate,
    this.calendarIds,
  });

  /// Create params for getting events for the current month
  factory GetCalendarEventsParams.currentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return GetCalendarEventsParams(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Create params for getting events for a specific month
  factory GetCalendarEventsParams.forMonth(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0);
    
    return GetCalendarEventsParams(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Create params for getting upcoming events (next 30 days)
  factory GetCalendarEventsParams.upcoming() {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));
    
    return GetCalendarEventsParams(
      startDate: now,
      endDate: thirtyDaysLater,
    );
  }
}

/// Permission failure specific to calendar
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}
