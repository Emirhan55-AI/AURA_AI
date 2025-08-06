import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/wardrobe_planner_controller.dart';
import '../widgets/wardrobe_planner/planner_header.dart';
import '../widgets/wardrobe_planner/outfit_card_dragger.dart';
import '../widgets/wardrobe_planner/planner_calendar.dart';
import '../widgets/wardrobe_planner/weather_widget.dart';
import '../widgets/wardrobe_planner/planner_stats_card.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/models/planned_outfit.dart';
import '../../../outfits/domain/entities/outfit.dart';

class WardrobePlannerScreen extends ConsumerStatefulWidget {
  const WardrobePlannerScreen({super.key});

  @override
  ConsumerState<WardrobePlannerScreen> createState() => _WardrobePlannerScreenState();
}

class _WardrobePlannerScreenState extends ConsumerState<WardrobePlannerScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wardrobePlannerControllerProvider.notifier).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wardrobePlannerControllerProvider);
    final controller = ref.read(wardrobePlannerControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Planner'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              state.isWeekView ? Icons.calendar_month : Icons.view_week,
            ),
            onPressed: () => controller.toggleViewMode(),
            tooltip: state.isWeekView ? 'Month View' : 'Week View',
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showStatsDialog(),
            tooltip: 'View Statistics',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
        },
        child: CustomScrollView(
          slivers: [
            // Header with date navigation
            SliverToBoxAdapter(
              child: PlannerHeader(
                selectedDate: state.selectedDate ?? DateTime.now(),
                onDateChanged: controller.setSelectedDate,
                onTodayPressed: () => controller.setSelectedDate(DateTime.now()),
              ),
            ),

            // Weather information
            state.weatherData.when(
              data: (weatherMap) {
                final selectedDate = state.selectedDate ?? DateTime.now();
                final weather = weatherMap[DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                )];
                
                if (weather != null) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: WeatherWidget(weather: weather),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
            ),

            // Available outfits for dragging
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Available Outfits',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: state.availableOutfits.length,
                        itemBuilder: (context, index) {
                          final outfit = state.availableOutfits[index];
                          return OutfitCardDragger(
                            outfit: outfit,
                            onDragStarted: () => controller.setDraggingOutfit(outfit),
                            onDragCompleted: () => controller.setDraggingOutfit(null),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main calendar view
            state.plannedOutfits.when(
              data: (plannedOutfits) => SliverToBoxAdapter(
                child: PlannerCalendar(
                  plannedOutfits: plannedOutfits,
                  selectedDate: state.selectedDate ?? DateTime.now(),
                  isWeekView: state.isWeekView,
                  draggingOutfit: state.draggingOutfit,
                  onDateSelected: controller.setSelectedDate,
                  onOutfitDropped: (Outfit outfit, DateTime date) =>
                      controller.planOutfitForDate(outfit, date),
                  onOutfitTapped: (PlannedOutfit plannedOutfit) => 
                      _showOutfitDetails(plannedOutfit),
                  onOutfitCompleted: (PlannedOutfit plannedOutfit) =>
                      controller.markOutfitCompleted(plannedOutfit.id),
                  onOutfitDeleted: (PlannedOutfit plannedOutfit) =>
                      controller.deletePlannedOutfit(plannedOutfit.id),
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading planned outfits...'),
                      ],
                    ),
                  ),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load planned outfits',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => controller.refreshData(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom padding for better scrolling experience
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOutfitDialog(),
        tooltip: 'Plan New Outfit',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final controller = ref.read(wardrobePlannerControllerProvider.notifier);
    
    switch (action) {
      case 'refresh':
        controller.refreshData();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showStatsDialog() {
    final stats = ref.read(wardrobePlannerControllerProvider).stats;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Planning Statistics'),
        content: stats != null 
            ? PlannerStatsCard(stats: stats)
            : const CircularProgressIndicator(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Planner Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Planning Reminders'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Weather Warnings'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.auto_awesome),
              title: Text('Smart Suggestions'),
              trailing: Switch(value: true, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCreateOutfitDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Outfit'),
        content: const Text(
          'This feature will allow you to create a new outfit directly from the planner. '
          'For now, please use the wardrobe screen to create outfits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to wardrobe screen
              context.pushNamed('/wardrobe');
            },
            child: const Text('Go to Wardrobe'),
          ),
        ],
      ),
    );
  }

  void _showOutfitDetails(PlannedOutfit plannedOutfit) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plannedOutfit.outfitName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plannedOutfit.outfitImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  plannedOutfit.outfitImageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Date: ${plannedOutfit.date.day}/${plannedOutfit.date.month}/${plannedOutfit.date.year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (plannedOutfit.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${plannedOutfit.notes}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (plannedOutfit.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: plannedOutfit.tags.map<Widget>((String tag) => 
                  Chip(
                    label: Text(tag),
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                ).toList(),
              ),
            ],
            if (plannedOutfit.isWeatherWarning) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plannedOutfit.weatherRecommendation ?? 
                        'Weather may not be suitable for this outfit',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!plannedOutfit.isCompleted)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(wardrobePlannerControllerProvider.notifier)
                    .markOutfitCompleted(plannedOutfit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Outfit marked as completed!'),
                  ),
                );
              },
              child: const Text('Mark Completed'),
            ),
        ],
      ),
    );
  }
}
