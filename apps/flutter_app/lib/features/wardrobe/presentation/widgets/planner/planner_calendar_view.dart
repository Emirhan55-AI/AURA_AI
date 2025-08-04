import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../outfits/domain/entities/outfit.dart';
import 'combination_drag_target.dart';
import 'weather_info_display.dart';
import 'weather_warning_banner.dart';

/// A widget to display the calendar and planned outfits
/// Integrates with table_calendar and shows planned outfits within date cells
class PlannerCalendarView extends StatefulWidget {
  final Map<DateTime, List<PlannedOutfit>> plannedOutfits;
  final Map<DateTime, WeatherData> weatherData;
  final void Function(Outfit outfit, DateTime date)? onAcceptOutfit;
  final void Function(PlannedOutfit plannedOutfit)? onRemoveOutfit;
  final void Function(DateTime date)? onDateSelected;
  final DateTime? selectedDate;

  const PlannerCalendarView({
    super.key,
    this.plannedOutfits = const {},
    this.weatherData = const {},
    this.onAcceptOutfit,
    this.onRemoveOutfit,
    this.onDateSelected,
    this.selectedDate,
  });

  @override
  State<PlannerCalendarView> createState() => _PlannerCalendarViewState();
}

class _PlannerCalendarViewState extends State<PlannerCalendarView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Weather warning banner for selected date
        if (_selectedDay != null && _hasWeatherWarning(_selectedDay!))
          _buildWeatherWarning(_selectedDay!),

        // Calendar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: TableCalendar<PlannedOutfit>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => widget.plannedOutfits[_normalizeDate(day)] ?? [],
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ) ?? const TextStyle(),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: colorScheme.onSurface,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ) ?? const TextStyle(),
              weekdayStyle: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
              ) ?? const TextStyle(),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ) ?? TextStyle(color: colorScheme.onSurfaceVariant),
              defaultTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => _buildCalendarCell(day),
              selectedBuilder: (context, day, focusedDay) => _buildCalendarCell(day, isSelected: true),
              todayBuilder: (context, day, focusedDay) => _buildCalendarCell(day, isToday: true),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected?.call(selectedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        ),

        // Weather info for selected date
        if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSelectedDateWeatherInfo(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarCell(DateTime day, {bool isSelected = false, bool isToday = false}) {
    final normalizedDay = _normalizeDate(day);
    final plannedOutfits = widget.plannedOutfits[normalizedDay] ?? [];
    final weatherData = widget.weatherData[normalizedDay];

    return CombinationDragTarget(
      date: day,
      plannedOutfits: plannedOutfits,
      weatherData: weatherData,
      onAcceptOutfit: widget.onAcceptOutfit,
      onRemoveOutfit: widget.onRemoveOutfit,
      onTap: () {
        setState(() {
          _selectedDay = day;
          _focusedDay = day;
        });
        widget.onDateSelected?.call(day);
      },
    );
  }

  Widget _buildWeatherWarning(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final weather = widget.weatherData[normalizedDate];
    
    if (weather == null) return const SizedBox.shrink();

    if (weather.temperature > 30) {
      return WeatherWarningBanner.temperature(
        temperature: weather.temperature,
        unit: weather.temperatureUnit,
      );
    } else if (weather.temperature < 5) {
      return WeatherWarningBanner.temperature(
        temperature: weather.temperature,
        unit: weather.temperatureUnit,
      );
    } else if (weather.condition.toLowerCase().contains('rain')) {
      return WeatherWarningBanner.rain();
    }

    return const SizedBox.shrink();
  }

  Widget _buildSelectedDateWeatherInfo() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final normalizedDate = _normalizeDate(_selectedDay!);
    final weather = widget.weatherData[normalizedDate];

    if (weather == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'No weather data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return WeatherInfoDisplay(weatherData: weather);
  }

  bool _hasWeatherWarning(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final weather = widget.weatherData[normalizedDate];
    
    if (weather == null) return false;
    
    return weather.temperature > 30 || 
           weather.temperature < 5 || 
           weather.condition.toLowerCase().contains('rain');
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
