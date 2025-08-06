import 'package:flutter/material.dart';
import '../../../domain/models/planned_outfit.dart';
import '../../../../outfits/domain/entities/outfit.dart';

class PlannerCalendar extends StatefulWidget {
  final List<PlannedOutfit> plannedOutfits;
  final DateTime selectedDate;
  final bool isWeekView;
  final Outfit? draggingOutfit;
  final ValueChanged<DateTime> onDateSelected;
  final Function(Outfit, DateTime) onOutfitDropped;
  final ValueChanged<PlannedOutfit> onOutfitTapped;
  final ValueChanged<PlannedOutfit> onOutfitCompleted;
  final ValueChanged<PlannedOutfit> onOutfitDeleted;

  const PlannerCalendar({
    super.key,
    required this.plannedOutfits,
    required this.selectedDate,
    required this.isWeekView,
    this.draggingOutfit,
    required this.onDateSelected,
    required this.onOutfitDropped,
    required this.onOutfitTapped,
    required this.onOutfitCompleted,
    required this.onOutfitDeleted,
  });

  @override
  State<PlannerCalendar> createState() => _PlannerCalendarState();
}

class _PlannerCalendarState extends State<PlannerCalendar> {
  late PageController _pageController;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
    _pageController = PageController(
      initialPage: _getInitialPage(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getInitialPage() {
    // Calculate the initial page based on the selected date
    final startDate = DateTime(2020, 1, 1);
    if (widget.isWeekView) {
      return _currentDate.difference(startDate).inDays ~/ 7;
    } else {
      return (_currentDate.year - startDate.year) * 12 + (_currentDate.month - startDate.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Calendar grid
          Container(
            height: widget.isWeekView ? 200 : 400,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return widget.isWeekView
                    ? _buildWeekView(index)
                    : _buildMonthView(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      if (widget.isWeekView) {
        final startDate = DateTime(2020, 1, 1);
        _currentDate = startDate.add(Duration(days: page * 7));
      } else {
        final startDate = DateTime(2020, 1, 1);
        _currentDate = DateTime(
          startDate.year + (page ~/ 12),
          startDate.month + (page % 12),
          1,
        );
      }
    });
  }

  Widget _buildWeekView(int pageIndex) {
    final startDate = DateTime(2020, 1, 1);
    final weekStart = startDate.add(Duration(days: pageIndex * 7));
    
    // Adjust to start of week (Monday)
    final adjustedWeekStart = weekStart.subtract(
      Duration(days: weekStart.weekday - 1),
    );

    return Column(
      children: [
        // Day headers
        Row(
          children: List.generate(7, (index) {
            final date = adjustedWeekStart.add(Duration(days: index));
            const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  dayNames[date.weekday - 1],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 8),
        
        // Date cells
        Expanded(
          child: Row(
            children: List.generate(7, (index) {
              final date = adjustedWeekStart.add(Duration(days: index));
              return Expanded(
                child: _buildDateCell(date),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView(int pageIndex) {
    final startDate = DateTime(2020, 1, 1);
    final monthDate = DateTime(
      startDate.year + (pageIndex ~/ 12),
      startDate.month + (pageIndex % 12),
      1,
    );
    
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final firstDayOfCalendar = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    return Column(
      children: [
        // Day headers
        Row(
          children: List.generate(7, (index) {
            final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  dayNames[index],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 8),
        
        // Calendar grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final date = firstDayOfCalendar.add(Duration(days: index));
              final isCurrentMonth = date.month == monthDate.month;
              
              return Opacity(
                opacity: isCurrentMonth ? 1.0 : 0.3,
                child: _buildDateCell(date),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateCell(DateTime date) {
    final plannedOutfit = _getPlannedOutfitForDate(date);
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isPast = date.isBefore(DateTime.now()) && !isToday;

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: DragTarget<Outfit>(
        onAccept: (outfit) => widget.onOutfitDropped(outfit, date),
        onWillAccept: (outfit) => outfit != null && !isPast,
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;
          
          return Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: _getDateCellColor(
                isSelected: isSelected,
                isToday: isToday,
                isPast: isPast,
                isHighlighted: isHighlighted,
                hasPlannedOutfit: plannedOutfit != null,
              ),
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : isHighlighted
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          width: 2,
                        )
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Date number
                Text(
                  date.day.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getDateTextColor(
                      isSelected: isSelected,
                      isToday: isToday,
                      isPast: isPast,
                      hasPlannedOutfit: plannedOutfit != null,
                    ),
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Planned outfit indicator
                if (plannedOutfit != null)
                  GestureDetector(
                    onTap: () => widget.onOutfitTapped(plannedOutfit),
                    onLongPress: () => _showOutfitOptions(plannedOutfit),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getOutfitStatusColor(plannedOutfit),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        plannedOutfit.isCompleted
                            ? Icons.check
                            : Icons.checkroom,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  )
                else if (isHighlighted)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  PlannedOutfit? _getPlannedOutfitForDate(DateTime date) {
    return widget.plannedOutfits.cast<PlannedOutfit?>().firstWhere(
      (outfit) => outfit != null && _isSameDay(outfit.date, date),
      orElse: () => null,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Color _getDateCellColor({
    required bool isSelected,
    required bool isToday,
    required bool isPast,
    required bool isHighlighted,
    required bool hasPlannedOutfit,
  }) {
    if (isHighlighted) {
      return Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5);
    }
    if (isSelected) {
      return Theme.of(context).colorScheme.primaryContainer;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.secondaryContainer;
    }
    if (hasPlannedOutfit) {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
    return Colors.transparent;
  }

  Color _getDateTextColor({
    required bool isSelected,
    required bool isToday,
    required bool isPast,
    required bool hasPlannedOutfit,
  }) {
    if (isSelected) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.onSecondaryContainer;
    }
    if (isPast) {
      return Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6);
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _getOutfitStatusColor(PlannedOutfit outfit) {
    switch (outfit.status) {
      case OutfitStatus.completed:
        return Colors.green;
      case OutfitStatus.planned:
        return Theme.of(context).colorScheme.primary;
      case OutfitStatus.cancelled:
        return Colors.red;
      case OutfitStatus.postponed:
        return Colors.orange;
    }
  }

  void _showOutfitOptions(PlannedOutfit outfit) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                widget.onOutfitTapped(outfit);
              },
            ),
            if (!outfit.isCompleted)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Mark as Completed'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onOutfitCompleted(outfit);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onOutfitDeleted(outfit);
              },
            ),
          ],
        ),
      ),
    );
  }
}
