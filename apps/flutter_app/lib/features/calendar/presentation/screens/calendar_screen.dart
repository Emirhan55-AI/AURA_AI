import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../widgets/event_list_item.dart';

/// Main calendar screen showing calendar view and events
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showCalendarSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Permission Banner
          if (!calendarState.hasPermission)
            _buildPermissionBanner(context, calendarState, calendarNotifier),

          // Calendar Widget
          _buildCalendar(context, calendarState, calendarNotifier),

          const Divider(height: 1),

          // Events List
          Expanded(
            child: _buildEventsList(context, calendarState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build permission banner when calendar access is not granted
  Widget _buildPermissionBanner(
    BuildContext context,
    CalendarState state,
    CalendarNotifier notifier,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: theme.colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar Access Required',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'To view and manage your calendar events, please grant calendar access permission.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: state.isRequestingPermission 
                ? null 
                : () => notifier.requestPermission(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: state.isRequestingPermission
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  /// Build the table calendar widget
  Widget _buildCalendar(
    BuildContext context,
    CalendarState state,
    CalendarNotifier notifier,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar<CalendarEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: state.focusedDate,
        selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          return state.events.when(
            data: (events) => events
                .where((event) =>
                  isSameDay(event.startTime, day) ||
                  (day.isAfter(event.startTime) && 
                   day.isBefore(event.endTime)))
                .toList(),
            loading: () => <CalendarEvent>[],
            error: (_, __) => <CalendarEvent>[],
          );
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(
            color: theme.colorScheme.error,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8.0),
          ),
          formatButtonTextStyle: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          notifier.updateSelectedDate(selectedDay);
          notifier.updateFocusedDate(focusedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          notifier.updateFocusedDate(focusedDay);
        },
      ),
    );
  }

  /// Build the events list for the selected date
  Widget _buildEventsList(
    BuildContext context,
    CalendarState state,
  ) {
    final theme = Theme.of(context);
    
    return state.events.when(
      data: (allEvents) {
        final selectedDateEvents = allEvents
            .where((event) => isSameDay(event.startTime, state.selectedDate))
            .toList();
        
        if (selectedDateEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No events for this date',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Tap the + button to add an event',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Events for ${_formatSelectedDate(state.selectedDate)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: selectedDateEvents.length,
                itemBuilder: (context, index) {
                  final event = selectedDateEvents[index];
                  return EventListItem(
                    event: event,
                    onTap: () => _showEventDetails(context, event),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Error loading events',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => ref.read(calendarNotifierProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Format selected date for display
  String _formatSelectedDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Show calendar settings dialog
  void _showCalendarSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Events'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(calendarNotifierProvider.notifier).refresh();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month),
              title: const Text('Available Calendars'),
              onTap: () {
                Navigator.of(context).pop();
                _showAvailableCalendars(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show available calendars dialog
  void _showAvailableCalendars(BuildContext context) {
    final calendarsState = ref.watch(calendarNotifierProvider.select(
      (state) => state.availableCalendars,
    ));
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Calendars'),
        content: SizedBox(
          width: double.maxFinite,
          child: calendarsState.when(
            data: (calendars) {
              if (calendars.isEmpty) {
                return const Text('No calendars found');
              }
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: calendars.length,
                itemBuilder: (context, index) {
                  final calendar = calendars[index];
                  return ListTile(
                    leading: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: calendar.color != null 
                            ? Color(int.parse(calendar.color!.replaceFirst('#', '0xFF')))
                            : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(calendar.name),
                    subtitle: Text(calendar.id),
                    trailing: Text(calendar.isReadOnly ? 'Read-only' : 'Editable'),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show add event dialog (placeholder)
  void _showAddEventDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: const Text(
          'Event creation will be implemented in a future update. '
          'For now, you can view events from your device calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show event details dialog
  void _showEventDetails(BuildContext context, CalendarEvent event) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description?.isNotEmpty == true) ...[
              Text(event.description!),
              const SizedBox(height: 16.0),
            ],
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8.0),
                Text(
                  event.isAllDay
                      ? 'All day'
                      : '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                ),
              ],
            ),
            if (event.location?.isNotEmpty == true) ...[
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8.0),
                  Expanded(child: Text(event.location!)),
                ],
              ),
            ],
            if (event.linkedOutfitId != null) ...[
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.checkroom, size: 16),
                  const SizedBox(width: 8.0),
                  const Text('Linked to outfit'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (event.linkedOutfitId == null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showOutfitLinkDialog(context, event);
              },
              child: const Text('Link Outfit'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show outfit link dialog (placeholder)
  void _showOutfitLinkDialog(BuildContext context, CalendarEvent event) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Outfit'),
        content: const Text(
          'Outfit linking will be implemented when the wardrobe feature is complete. '
          'This will allow you to link outfits to calendar events for outfit suggestions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Format time for display
  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
