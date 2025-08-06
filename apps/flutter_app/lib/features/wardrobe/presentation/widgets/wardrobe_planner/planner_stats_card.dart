import 'package:flutter/material.dart';

class PlannerStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const PlannerStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final totalPlanned = stats['totalPlanned'] ?? 0;
    final completedOutfits = stats['completedOutfits'] ?? 0;
    final upcomingOutfits = stats['upcomingOutfits'] ?? 0;
    final completionRate = stats['completionRate'] ?? 0.0;
    final averageWearTime = stats['averageWearTime'] ?? 0.0;
    final mostPlannedDay = stats['mostPlannedDay'] ?? 'N/A';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Planned',
                  totalPlanned.toString(),
                  Icons.calendar_today,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completed',
                  completedOutfits.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Upcoming',
                  upcomingOutfits.toString(),
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completion Rate',
                  '${(completionRate * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Additional stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Insights',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    context,
                    'Average Wear Time',
                    '${averageWearTime.toStringAsFixed(1)} hours',
                    Icons.access_time,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildInfoRow(
                    context,
                    'Most Planned Day',
                    mostPlannedDay,
                    Icons.star,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildInfoRow(
                    context,
                    'Planning Streak',
                    '${stats['planningStreak'] ?? 0} days',
                    Icons.local_fire_department,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress indicators
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress This Week',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildProgressBar(
                    context,
                    'Outfits Planned',
                    (stats['weeklyPlanned'] ?? 0) / 7.0,
                    '${stats['weeklyPlanned'] ?? 0}/7',
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildProgressBar(
                    context,
                    'Goals Completed',
                    (stats['goalsCompleted'] ?? 0) / (stats['totalGoals'] ?? 1),
                    '${stats['goalsCompleted'] ?? 0}/${stats['totalGoals'] ?? 0}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String title,
    double progress,
    String label,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
