import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../services/device_calendar_service.dart';

/// Implementation of CalendarRepository using device calendar
/// Handles data access for calendar events following Clean Architecture
class CalendarRepositoryImpl implements CalendarRepository {
  final DeviceCalendarService _deviceCalendarService;

  const CalendarRepositoryImpl(this._deviceCalendarService);

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? calendarIds,
  }) async {
    try {
      final eventModels = await _deviceCalendarService.fetchEvents(
        startDate: startDate,
        endDate: endDate,
        calendarIds: calendarIds,
      );

      final domainEvents = eventModels
          .map((model) => model.toDomainEntity())
          .toList();

      return Right(domainEvents);
    } on CalendarPermissionException catch (e) {
      return Left(PermissionFailure(
        message: e.message,
        code: 'CALENDAR_PERMISSION_DENIED',
      ));
    } on CalendarServiceException catch (e) {
      return Left(ServiceFailure(
        message: e.message,
        code: 'CALENDAR_SERVICE_ERROR',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to fetch calendar events: ${e.toString()}',
        code: 'CALENDAR_FETCH_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEventsForDate(
    DateTime date,
  ) async {
    try {
      final eventModels = await _deviceCalendarService.fetchEventsForDate(date);

      final domainEvents = eventModels
          .map((model) => model.toDomainEntity())
          .toList();

      return Right(domainEvents);
    } on CalendarPermissionException catch (e) {
      return Left(PermissionFailure(
        message: e.message,
        code: 'CALENDAR_PERMISSION_DENIED',
      ));
    } on CalendarServiceException catch (e) {
      return Left(ServiceFailure(
        message: e.message,
        code: 'CALENDAR_SERVICE_ERROR',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to fetch events for date: ${e.toString()}',
        code: 'CALENDAR_FETCH_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> hasCalendarPermission() async {
    try {
      final hasPermission = await _deviceCalendarService.hasCalendarPermission();
      return Right(hasPermission);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to check calendar permission: ${e.toString()}',
        code: 'PERMISSION_CHECK_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> requestCalendarPermission() async {
    try {
      final granted = await _deviceCalendarService.requestCalendarPermission();
      return Right(granted);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to request calendar permission: ${e.toString()}',
        code: 'PERMISSION_REQUEST_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<CalendarInfo>>> getAvailableCalendars() async {
    try {
      final calendarModels = await _deviceCalendarService.getAvailableCalendars();

      final calendarInfos = calendarModels
          .map((model) => CalendarInfo(
                id: model.id,
                name: model.name,
                color: model.color,
                isReadOnly: model.isReadOnly,
                isDefault: model.isDefault,
              ))
          .toList();

      return Right(calendarInfos);
    } on CalendarPermissionException catch (e) {
      return Left(PermissionFailure(
        message: e.message,
        code: 'CALENDAR_PERMISSION_DENIED',
      ));
    } on CalendarServiceException catch (e) {
      return Left(ServiceFailure(
        message: e.message,
        code: 'CALENDAR_SERVICE_ERROR',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to get available calendars: ${e.toString()}',
        code: 'CALENDAR_LIST_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> linkOutfitToEvent(
    String eventId,
    String? outfitId,
  ) async {
    // TODO: Implement outfit linking functionality
    // This will be implemented when outfit integration is added
    return Left(UnknownFailure(
      message: 'Outfit linking is not yet implemented',
      code: 'FEATURE_NOT_IMPLEMENTED',
    ));
  }
}

/// Custom failure types for calendar operations
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}
