import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

class SimpleOutfitPlannerScreen extends ConsumerStatefulWidget {
  const SimpleOutfitPlannerScreen({super.key});

  @override
  ConsumerState<SimpleOutfitPlannerScreen> createState() => _SimpleOutfitPlannerScreenState();
}

class _SimpleOutfitPlannerScreenState extends ConsumerState<SimpleOutfitPlannerScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _outfitPlans = {};
  
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    // Sample data
    _outfitPlans = {
      DateTime.now(): ['Work outfit - Blue shirt & black pants'],
      DateTime.now().add(const Duration(days: 1)): ['Casual - Jeans & t-shirt'],
      DateTime.now().add(const Duration(days: 3)): ['Formal - Black dress'],
    };
  }

  List<String> _getPlansForDay(DateTime day) {
    // Normalize the DateTime to compare only date part
    final normalizedDay = DateTime(day.year, day.month, day.day);
    for (final entry in _outfitPlans.entries) {
      final normalizedEntryDay = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (normalizedEntryDay.isAtSameMomentAs(normalizedDay)) {
        return entry.value;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Outfit Planner',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              // Analytics functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar<String>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getPlansForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Plans for selected day
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plans for ${_selectedDay != null ? '${_selectedDay!.day}/${_selectedDay!.month}' : 'today'}',
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddPlanDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Plan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: _selectedDay == null 
                        ? const Center(child: Text('Select a day to view plans'))
                        : _buildPlansList(colorScheme, theme),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlanDialog(context),
        label: const Text('Plan Outfit'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlansList(ColorScheme colorScheme, ThemeData theme) {
    final plans = _getPlansForDay(_selectedDay!);
    
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No outfit plans for this day',
              style: theme.textTheme.bodyLarge!.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showAddPlanDialog(context),
              child: const Text('Create your first plan'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.checkroom,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(plan),
            subtitle: Text('Planned for ${_selectedDay!.day}/${_selectedDay!.month}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditPlanDialog(context, index, plan);
                } else if (value == 'delete') {
                  _deletePlan(index);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPlanDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Outfit Plan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Describe your outfit',
            hintText: 'e.g., Blue shirt with black pants',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty && _selectedDay != null) {
                _addPlan(controller.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(BuildContext context, int index, String currentPlan) {
    final TextEditingController controller = TextEditingController(text: currentPlan);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Outfit Plan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Describe your outfit',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _editPlan(index, controller.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addPlan(String planDescription) {
    if (_selectedDay != null) {
      setState(() {
        final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        if (_outfitPlans.containsKey(normalizedDay)) {
          _outfitPlans[normalizedDay]!.add(planDescription);
        } else {
          _outfitPlans[normalizedDay] = [planDescription];
        }
      });
    }
  }

  void _editPlan(int index, String newDescription) {
    if (_selectedDay != null) {
      setState(() {
        final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        if (_outfitPlans.containsKey(normalizedDay)) {
          _outfitPlans[normalizedDay]![index] = newDescription;
        }
      });
    }
  }

  void _deletePlan(int index) {
    if (_selectedDay != null) {
      setState(() {
        final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        if (_outfitPlans.containsKey(normalizedDay)) {
          _outfitPlans[normalizedDay]!.removeAt(index);
          if (_outfitPlans[normalizedDay]!.isEmpty) {
            _outfitPlans.remove(normalizedDay);
          }
        }
      });
    }
  }
}
