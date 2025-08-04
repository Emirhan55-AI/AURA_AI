import 'package:flutter/material.dart';

import '../../domain/entities/calendar_event.dart';

/// Widget for displaying a calendar event item in a list
class EventListItem extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;
  final bool showDate;

  const EventListItem({
    super.key,
    required this.event,
    this.onTap,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event title and time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar color indicator
                  if (event.calendarColor != null)
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _parseColor(event.calendarColor!),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  if (event.calendarColor != null) const SizedBox(width: 12),
                  
                  // Event details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Time and date info
                        Row(
                          children: [
                            Icon(
                              event.isAllDay ? Icons.event : Icons.access_time,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatEventTime(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicators
                  Column(
                    children: [
                      if (event.isHappening)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Now',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (event.linkedOutfitId != null) ...[
                        const SizedBox(height: 4),
                        Icon(
                          Icons.checkroom,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              // Location and description
              if (event.location != null || event.description != null) ...[
                const SizedBox(height: 8),
                if (event.location != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.description != null && event.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
              
              // Event type suggestion chip
              if (event.suggestedEventType != 'casual') ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        event.suggestedEventType?.toUpperCase() ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    if (event.isSuitableForOutfitSuggestion)
                      Chip(
                        label: Text(
                          'OUTFIT READY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: colorScheme.tertiaryContainer,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Format event time based on whether it's all day or has specific times
  String _formatEventTime() {
    if (event.isAllDay) {
      if (showDate) {
        return '${_formatDate(event.startTime)} - All Day';
      }
      return 'All Day';
    }

    if (showDate) {
      return '${_formatDate(event.startTime)} ${event.timeRange}';
    }
    
    return event.timeRange;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Parse color string to Color object
  Color _parseColor(String colorString) {
    try {
      // Remove # if present and ensure 8 characters (ARGB)
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor'; // Add full opacity
      }
      return Color(int.parse(cleanColor, radix: 16));
    } catch (e) {
      // Return default color if parsing fails
      return Colors.blue;
    }
  }
}
