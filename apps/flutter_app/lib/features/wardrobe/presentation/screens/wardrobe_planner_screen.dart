import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../../../outfits/domain/entities/outfit.dart';
import '../widgets/planner/planner_calendar_view.dart';
import '../widgets/planner/draggable_combination_card.dart';
import '../widgets/planner/combination_drag_target.dart';
import '../controllers/wardrobe_planner_controller.dart';

/// Screen for planning outfits on a calendar view with weather integration
/// Allows users to drag and drop outfits onto calendar dates and get weather-based suggestions
class WardrobePlannerScreen extends ConsumerWidget {
  const WardrobePlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(wardrobePlannerControllerProvider);
    final notifier = ref.read(wardrobePlannerControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen for operations that might require user feedback (e.g., dialogs)
    _listenForPendingDrops(context, ref);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Planner',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () => notifier.loadPlannedOutfits(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(context, controller, notifier),
    );
  }

  Widget _buildBody(BuildContext context, WardrobePlannerState state, WardrobePlannerController notifier) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle loading state
    if (state.plannedOutfits.isLoading) {
      return const SystemStateWidget(
        icon: Icons.calendar_today,
        message: 'Loading your planner...',
      );
    }

    // Handle error state
    if (state.plannedOutfits.hasError) {
      return SystemStateWidget(
        icon: Icons.error_outline,
        title: 'Unable to Load Planner',
        message: 'We couldn\'t load your outfit plans. Please check your connection and try again.',
        onRetry: () => notifier.retryLoadPlannedOutfits(),
        retryText: 'Try Again',
        iconColor: colorScheme.error,
      );
    }

    // Weather loading error is handled separately and doesn't block the main UI
    if (state.weatherData.hasError) {
      return Column(
        children: [
          _buildWeatherErrorBanner(context, notifier),
          Expanded(child: _buildMainContent(context, state, notifier)),
        ],
      );
    }

    return _buildMainContent(context, state, notifier);
  }

  Widget _buildMainContent(BuildContext context, WardrobePlannerState state, WardrobePlannerController notifier) {
    return Column(
      children: [
        _buildDraggableOutfitsSection(context, state, notifier),
        Expanded(child: _buildCalendarView(context, state, notifier)),
      ],
    );
  }

  Widget _buildDraggableOutfitsSection(BuildContext context, WardrobePlannerState state, WardrobePlannerController notifier) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.drag_indicator,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Drag outfits to plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.availableOutfits.isNotEmpty
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.availableOutfits.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final outfit = state.availableOutfits[index];
                      return DraggableCombinationCard(
                        outfit: outfit,
                        onDragStarted: () => notifier.startDraggingOutfit(outfit),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No outfits available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, WardrobePlannerState state, WardrobePlannerController notifier) {
    final plannedOutfitsByDate = <DateTime, List<PlannedOutfit>>{};
    final plannedOutfits = state.plannedOutfits.valueOrNull ?? [];
    
    for (final plannedOutfit in plannedOutfits) {
      final normalizedDate = DateTime(
        plannedOutfit.date.year,
        plannedOutfit.date.month,
        plannedOutfit.date.day,
      );
      
      if (plannedOutfitsByDate.containsKey(normalizedDate)) {
        plannedOutfitsByDate[normalizedDate]!.add(plannedOutfit);
      } else {
        plannedOutfitsByDate[normalizedDate] = [plannedOutfit];
      }
    }

    return PlannerCalendarView(
      plannedOutfits: plannedOutfitsByDate,
      weatherData: state.weatherData.valueOrNull ?? {},
      selectedDate: state.selectedDate,
      onAcceptOutfit: (outfit, date) => _handleAcceptOutfit(context, notifier, outfit, date),
      onRemoveOutfit: (plannedOutfit) => _handleRemoveOutfit(context, notifier, plannedOutfit),
      onDateSelected: (date) => notifier.selectDate(date),
    );
  }

  Widget _buildWeatherErrorBanner(BuildContext context, WardrobePlannerController notifier) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.warning, color: colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Weather data unavailable',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () => notifier.retryLoadWeatherData(),
            child: Text(
              'Retry',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  void _listenForPendingDrops(BuildContext context, WidgetRef ref) {
    ref.listen<PlannedOutfit?>(
      wardrobePlannerControllerProvider.select((state) => state.pendingDropPlan),
      (previous, next) {
        if (next != null) {
          _showWeatherWarningDialog(context, ref.read(wardrobePlannerControllerProvider.notifier), next);
        }
      },
    );
  }

  void _showWeatherWarningDialog(BuildContext context, WardrobePlannerController notifier, PlannedOutfit plan) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Weather Warning'),
          content: const Text('The weather for this day might not be suitable for the selected outfit. Are you sure you want to plan it?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                notifier.cancelPendingDrop();
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Plan Anyway'),
              onPressed: () {
                notifier.confirmDropPlan(plan);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleAcceptOutfit(BuildContext context, WardrobePlannerController notifier, Outfit outfit, DateTime date) {
    notifier.dropOutfit(date, outfit);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${outfit.name} planned for ${_formatDate(date)}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleRemoveOutfit(BuildContext context, WardrobePlannerController notifier, PlannedOutfit plannedOutfit) {
    notifier.removePlannedOutfit(plannedOutfit.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plannedOutfit.outfit.name} removed from plan'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Route generator for WardrobePlannerScreen
class WardrobePlannerRoute {
  static const String name = '/wardrobe-planner';

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: name),
      builder: (context) => const WardrobePlannerScreen(),
    );
  }
}

/// Extension for easy navigation
extension WardrobePlannerNavigation on NavigatorState {
  Future<void> pushWardrobePlanner() {
    return push(WardrobePlannerRoute.route());
  }
}
