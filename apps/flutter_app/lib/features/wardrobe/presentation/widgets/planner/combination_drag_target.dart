import 'package:flutter/material.dart';
import '../../../../outfits/domain/entities/outfit.dart';

/// A simple data class for weather information
class WeatherData {
  final String condition; // 'sunny', 'cloudy', 'rainy', 'snowy', etc.
  final int temperature;
  final String temperatureUnit;
  final String description;
  final IconData icon;

  const WeatherData({
    required this.condition,
    required this.temperature,
    this.temperatureUnit = '°C',
    required this.description,
    required this.icon,
  });

  // Factory constructor for placeholder data
  factory WeatherData.placeholder() {
    return const WeatherData(
      condition: 'sunny',
      temperature: 22,
      description: 'Sunny',
      icon: Icons.wb_sunny,
    );
  }
}

/// A simple data class for planned outfits
class PlannedOutfit {
  final String id;
  final DateTime date;
  final String outfitId;
  final Outfit outfit;

  const PlannedOutfit({
    required this.id,
    required this.date,
    required this.outfitId,
    required this.outfit,
  });
}

/// A drag target widget that represents the drop zone on a calendar date
/// Visually indicates when a draggable item is hovering over it
class CombinationDragTarget extends StatefulWidget {
  final DateTime date;
  final List<PlannedOutfit> plannedOutfits;
  final WeatherData? weatherData;
  final void Function(Outfit outfit, DateTime date)? onAcceptOutfit;
  final void Function(PlannedOutfit plannedOutfit)? onRemoveOutfit;
  final VoidCallback? onTap;

  const CombinationDragTarget({
    super.key,
    required this.date,
    this.plannedOutfits = const [],
    this.weatherData,
    this.onAcceptOutfit,
    this.onRemoveOutfit,
    this.onTap,
  });

  @override
  State<CombinationDragTarget> createState() => _CombinationDragTargetState();
}

class _CombinationDragTargetState extends State<CombinationDragTarget> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateTime.now();
    final isToday = widget.date.day == today.day &&
        widget.date.month == today.month &&
        widget.date.year == today.year;

    return DragTarget<Outfit>(
      onAccept: (outfit) {
        widget.onAcceptOutfit?.call(outfit, widget.date);
        setState(() {
          _isDragOver = false;
        });
      },
      onWillAccept: (outfit) => outfit != null,
      onMove: (details) {
        if (!_isDragOver) {
          setState(() {
            _isDragOver = true;
          });
        }
      },
      onLeave: (outfit) {
        setState(() {
          _isDragOver = false;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isDragOver
                  ? colorScheme.primaryContainer.withOpacity(0.3)
                  : (isToday
                      ? colorScheme.primaryContainer.withOpacity(0.1)
                      : null),
              border: _isDragOver
                  ? Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    )
                  : (isToday
                      ? Border.all(
                          color: colorScheme.primary,
                          width: 1,
                        )
                      : null),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.date.day}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? colorScheme.primary : null,
                      ),
                    ),
                    // Weather icon
                    if (widget.weatherData != null)
                      Icon(
                        widget.weatherData!.icon,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
                
                const SizedBox(height: 2),
                
                // Temperature
                if (widget.weatherData != null)
                  Text(
                    '${widget.weatherData!.temperature}${widget.weatherData!.temperatureUnit}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                
                const SizedBox(height: 4),
                
                // Planned outfits
                Expanded(
                  child: widget.plannedOutfits.isEmpty
                      ? _isDragOver
                          ? Center(
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                            )
                          : const SizedBox.shrink()
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: widget.plannedOutfits.length,
                          itemBuilder: (context, index) {
                            final plannedOutfit = widget.plannedOutfits[index];
                            return Container(
                              height: 20,
                              margin: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      plannedOutfit.outfit.name,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontSize: 9,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => widget.onRemoveOutfit?.call(plannedOutfit),
                                    child: Icon(
                                      Icons.close,
                                      size: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
