import 'package:flutter/material.dart';
import '../../../controllers/style_discovery_controller.dart';

/// SliderCard - Slider interface for numerical style preferences
/// 
/// Allows users to select a value within a range using a slider.
class SliderCard extends StatefulWidget {
  final StyleQuestion question;
  final StyleAnswer? currentAnswer;
  final void Function(double) onAnswer;

  const SliderCard({
    super.key,
    required this.question,
    required this.currentAnswer,
    required this.onAnswer,
  });

  @override
  State<SliderCard> createState() => _SliderCardState();
}

class _SliderCardState extends State<SliderCard> {
  late double _currentValue;
  late double _minValue;
  late double _maxValue;

  @override
  void initState() {
    super.initState();
    
    // Parse min/max from question metadata or use defaults
    _minValue = widget.question.metadata?['min']?.toDouble() ?? 0.0;
    _maxValue = widget.question.metadata?['max']?.toDouble() ?? 100.0;
    
    _currentValue = widget.currentAnswer?.numberValue ?? 
                    widget.question.metadata?['default']?.toDouble() ?? 
                    (_minValue + _maxValue) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question title
        _buildQuestionTitle(theme, colorScheme),
        
        const SizedBox(height: 48),
        
        // Slider section
        Expanded(
          child: _buildSliderSection(theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildQuestionTitle(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (widget.question.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderSection(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Current value display
          _buildValueDisplay(theme, colorScheme),
          
          const SizedBox(height: 48),
          
          // Slider
          _buildSlider(theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Min/Max labels
          _buildLabels(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(ThemeData theme, ColorScheme colorScheme) {
    final valueText = _formatValue(_currentValue);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Your Selection',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valueText,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(ThemeData theme, ColorScheme colorScheme) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceVariant,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.1),
        trackHeight: 8.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
      ),
      child: Slider(
        value: _currentValue,
        min: _minValue,
        max: _maxValue,
        divisions: (_maxValue - _minValue).round(),
        onChanged: (value) {
          setState(() {
            _currentValue = value;
          });
          widget.onAnswer(value);
        },
      ),
    );
  }

  Widget _buildLabels(ThemeData theme, ColorScheme colorScheme) {
    final minLabel = widget.question.metadata?['minLabel'] ?? _minValue.toString();
    final maxLabel = widget.question.metadata?['maxLabel'] ?? _maxValue.toString();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          minLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          maxLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) {
    final suffix = widget.question.metadata?['suffix'] ?? '';
    final prefix = widget.question.metadata?['prefix'] ?? '';
    
    if (value == value.roundToDouble()) {
      return '$prefix${value.round()}$suffix';
    } else {
      return '$prefix${value.toStringAsFixed(1)}$suffix';
    }
  }
}
