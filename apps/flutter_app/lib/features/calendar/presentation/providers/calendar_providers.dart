import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../../data/services/calendar_permission_service.dart';
import '../../data/services/device_calendar_service.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../domain/usecases/get_calendar_events_use_case.dart';

/// Provider for CalendarPermissionService
final calendarPermissionServiceProvider = Provider<CalendarPermissionService>((ref) {
  return CalendarPermissionService();
});

/// Provider for DeviceCalendarService
final deviceCalendarServiceProvider = Provider<DeviceCalendarService>((ref) {
  final permissionService = ref.watch(calendarPermissionServiceProvider);
  return DeviceCalendarService(permissionService: permissionService);
});

/// Provider for CalendarRepository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final deviceCalendarService = ref.watch(deviceCalendarServiceProvider);
  return CalendarRepositoryImpl(deviceCalendarService);
});

/// Provider for GetCalendarEventsUseCase
final getCalendarEventsUseCaseProvider = Provider<GetCalendarEventsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetCalendarEventsUseCase(repository);
});

/// Provider for GetEventsForDateUseCase
final getEventsForDateUseCaseProvider = Provider<GetEventsForDateUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetEventsForDateUseCase(repository);
});

/// Provider for RequestCalendarPermissionUseCase
final requestCalendarPermissionUseCaseProvider = Provider<RequestCalendarPermissionUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return RequestCalendarPermissionUseCase(repository);
});

/// Provider for GetAvailableCalendarsUseCase
final getAvailableCalendarsUseCaseProvider = Provider<GetAvailableCalendarsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetAvailableCalendarsUseCase(repository);
});

/// State notifier for calendar screen state management
final calendarNotifierProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final getEventsUseCase = ref.watch(getCalendarEventsUseCaseProvider);
  final requestPermissionUseCase = ref.watch(requestCalendarPermissionUseCaseProvider);
  final getCalendarsUseCase = ref.watch(getAvailableCalendarsUseCaseProvider);
  final repository = ref.watch(calendarRepositoryProvider);
  
  return CalendarNotifier(
    getEventsUseCase,
    requestPermissionUseCase,
    getCalendarsUseCase,
    repository,
  );
});

/// Provider for currently selected date
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider for calendar view mode
final calendarViewModeProvider = StateProvider<CalendarViewMode>((ref) {
  return CalendarViewMode.month;
});

/// State class for calendar screen
class CalendarState {
  final AsyncValue<List<CalendarEvent>> events;
  final AsyncValue<List<CalendarInfo>> availableCalendars;
  final bool hasPermission;
  final bool isRequestingPermission;
  final DateTime focusedDate;
  final DateTime selectedDate;
  final String? errorMessage;

  const CalendarState({
    this.events = const AsyncValue.loading(),
    this.availableCalendars = const AsyncValue.loading(),
    this.hasPermission = false,
    this.isRequestingPermission = false,
    required this.focusedDate,
    required this.selectedDate,
    this.errorMessage,
  });

  CalendarState copyWith({
    AsyncValue<List<CalendarEvent>>? events,
    AsyncValue<List<CalendarInfo>>? availableCalendars,
    bool? hasPermission,
    bool? isRequestingPermission,
    DateTime? focusedDate,
    DateTime? selectedDate,
    String? errorMessage,
  }) {
    return CalendarState(
      events: events ?? this.events,
      availableCalendars: availableCalendars ?? this.availableCalendars,
      hasPermission: hasPermission ?? this.hasPermission,
      isRequestingPermission: isRequestingPermission ?? this.isRequestingPermission,
      focusedDate: focusedDate ?? this.focusedDate,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// State notifier for managing calendar state
class CalendarNotifier extends StateNotifier<CalendarState> {
  final GetCalendarEventsUseCase _getEventsUseCase;
  final RequestCalendarPermissionUseCase _requestPermissionUseCase;
  final GetAvailableCalendarsUseCase _getCalendarsUseCase;
  final CalendarRepository _repository;

  CalendarNotifier(
    this._getEventsUseCase,
    this._requestPermissionUseCase,
    this._getCalendarsUseCase,
    this._repository,
  ) : super(CalendarState(
          focusedDate: DateTime.now(),
          selectedDate: DateTime.now(),
        )) {
    _initialize();
  }

  /// Initialize the calendar by checking permissions and loading data
  Future<void> _initialize() async {
    await checkPermissionAndLoadData();
  }

  /// Check permission status and load calendar data if permitted
  Future<void> checkPermissionAndLoadData() async {
    // Use the repository directly
    final permissionResult = await _repository.hasCalendarPermission();
    
    permissionResult.fold(
      (Failure failure) {
        state = state.copyWith(
          hasPermission: false,
          errorMessage: failure.message,
        );
      },
      (bool hasPermission) {
        state = state.copyWith(hasPermission: hasPermission);
        
        if (hasPermission) {
          // Load calendar data
          loadEventsForCurrentMonth();
          loadAvailableCalendars();
        }
      },
    );
  }

  /// Request calendar permission from user
  Future<void> requestPermission() async {
    state = state.copyWith(isRequestingPermission: true);
    
    final result = await _requestPermissionUseCase.call();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isRequestingPermission: false,
          hasPermission: false,
          errorMessage: failure.message,
        );
      },
      (granted) {
        state = state.copyWith(
          isRequestingPermission: false,
          hasPermission: granted,
        );
        
        if (granted) {
          // Load data now that we have permission
          loadEventsForCurrentMonth();
          loadAvailableCalendars();
        }
      },
    );
  }

  /// Load events for the current month
  Future<void> loadEventsForCurrentMonth() async {
    state = state.copyWith(events: const AsyncValue.loading());
    
    final params = GetCalendarEventsParams.forMonth(
      state.focusedDate.year,
      state.focusedDate.month,
    );
    
    final result = await _getEventsUseCase.call(params);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          events: AsyncValue.error(failure, StackTrace.current),
          errorMessage: failure.message,
        );
      },
      (events) {
        state = state.copyWith(
          events: AsyncValue.data(events),
          errorMessage: null,
        );
      },
    );
  }

  /// Load events for a specific date range
  Future<void> loadEventsForDateRange(DateTime start, DateTime end) async {
    state = state.copyWith(events: const AsyncValue.loading());
    
    final params = GetCalendarEventsParams(
      startDate: start,
      endDate: end,
    );
    
    final result = await _getEventsUseCase.call(params);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          events: AsyncValue.error(failure, StackTrace.current),
          errorMessage: failure.message,
        );
      },
      (events) {
        state = state.copyWith(
          events: AsyncValue.data(events),
          errorMessage: null,
        );
      },
    );
  }

  /// Load available calendars
  Future<void> loadAvailableCalendars() async {
    state = state.copyWith(availableCalendars: const AsyncValue.loading());
    
    final result = await _getCalendarsUseCase.call();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          availableCalendars: AsyncValue.error(failure, StackTrace.current),
        );
      },
      (calendars) {
        state = state.copyWith(
          availableCalendars: AsyncValue.data(calendars),
        );
      },
    );
  }

  /// Update focused date (for calendar navigation)
  void updateFocusedDate(DateTime date) {
    state = state.copyWith(focusedDate: date);
    // Reload events for the new month if month changed
    if (date.month != state.focusedDate.month || date.year != state.focusedDate.year) {
      loadEventsForCurrentMonth();
    }
  }

  /// Update selected date
  void updateSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Refresh all calendar data
  Future<void> refresh() async {
    if (state.hasPermission) {
      await Future.wait([
        loadEventsForCurrentMonth(),
        loadAvailableCalendars(),
      ]);
    } else {
      await checkPermissionAndLoadData();
    }
  }
}

/// Enum for calendar view modes
enum CalendarViewMode {
  month,
  week,
  day,
}
