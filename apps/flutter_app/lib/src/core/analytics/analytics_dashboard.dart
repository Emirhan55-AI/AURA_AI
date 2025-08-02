import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_providers.dart';
import 'analytics_service.dart';

/// Analytics dashboard for monitoring app usage and performance
class AnalyticsDashboard extends ConsumerWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsControllerProvider);
    final analyticsController = ref.read(analyticsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await analyticsController.initialize();
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final data = await analyticsController.exportData();
              if (data != null && context.mounted) {
                _showExportDialog(context, data);
              }
            },
          ),
        ],
      ),
      body: _buildDashboardContent(context, analyticsState, analyticsController),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AnalyticsState state,
    AnalyticsController controller,
  ) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading analytics...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.initialize(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!state.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 64),
            const SizedBox(height: 16),
            const Text('Analytics not initialized'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.initialize(),
              child: const Text('Initialize Analytics'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSection(state.summary),
          const SizedBox(height: 24),
          _buildMetricsSection(state.summary),
          const SizedBox(height: 24),
          _buildUserPropertiesSection(state.summary),
          const SizedBox(height: 24),
          _buildActionsSection(context, controller),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(AnalyticsSummary? summary) {
    if (summary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No analytics data available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Events',
                    summary.totalEvents.toString(),
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Recent Events',
                    summary.recentEvents.toString(),
                    Icons.schedule,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Event Types',
                    summary.uniqueEventTypes.toString(),
                    Icons.category,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Sessions',
                    summary.sessionCount.toString(),
                    Icons.play_circle,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(AnalyticsSummary? summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (summary?.lastEventTime != null) ...[
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Last Event'),
                subtitle: Text(_formatDateTime(summary!.lastEventTime!)),
              ),
            ],
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Engagement Rate'),
              subtitle: Text('${_calculateEngagementRate(summary)}%'),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Event Frequency'),
              subtitle: Text(_calculateEventFrequency(summary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPropertiesSection(AnalyticsSummary? summary) {
    final userProperties = summary?.userProperties ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Properties',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (userProperties.isEmpty) ...[
              const Text('No user properties set'),
            ] else ...[
              ...userProperties.entries.map((entry) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, AnalyticsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.event),
                  label: const Text('Test Event'),
                  onPressed: () => _trackTestEvent(controller),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Set Property'),
                  onPressed: () => _showSetPropertyDialog(context, controller),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export Data'),
                  onPressed: () async {
                    final data = await controller.exportData();
                    if (data != null && context.mounted) {
                      _showExportDialog(context, data);
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Data'),
                  onPressed: () => _showClearDataDialog(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _trackTestEvent(AnalyticsController controller) {
    controller.trackEvent('dashboard_test_event', {
      'timestamp': DateTime.now().toIso8601String(),
      'source': 'analytics_dashboard',
    });
  }

  void _showSetPropertyDialog(BuildContext context, AnalyticsController controller) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set User Property'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Property Name',
                hintText: 'e.g., user_level',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Property Value',
                hintText: 'e.g., advanced',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                controller.setUserProperty(
                  nameController.text,
                  valueController.text,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics Data'),
        content: SingleChildScrollView(
          child: SelectableText(
            'Total Events: ${data['total_events']}\n'
            'Export Time: ${data['export_timestamp']}\n\n'
            'Data preview:\n${data.toString().substring(0, 200)}...',
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

  void _showClearDataDialog(BuildContext context, AnalyticsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Analytics Data'),
        content: const Text(
          'This will permanently delete all analytics data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearData();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  double _calculateEngagementRate(AnalyticsSummary? summary) {
    if (summary == null || summary.totalEvents == 0) return 0.0;
    return (summary.recentEvents / summary.totalEvents) * 100;
  }

  String _calculateEventFrequency(AnalyticsSummary? summary) {
    if (summary == null || summary.sessionCount == 0) return 'No data';
    final eventsPerSession = summary.totalEvents / summary.sessionCount;
    return '${eventsPerSession.toStringAsFixed(1)} events/session';
  }
}
