import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';

class ExportOptionsDialog extends StatefulWidget {
  final Function(List<String>, String) onExport;

  const ExportOptionsDialog({
    super.key,
    required this.onExport,
  });

  @override
  State<ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<ExportOptionsDialog> {
  final Map<String, bool> _selectedSections = {
    'overview': true,
    'usage_stats': true,
    'category_analysis': false,
    'color_analysis': false,
    'sustainability': false,
    'recommendations': false,
    'insights': false,
  };

  String _selectedFormat = 'pdf';

  final Map<String, String> _sectionLabels = {
    'overview': 'Overview & Summary',
    'usage_stats': 'Usage Statistics',
    'category_analysis': 'Category Analysis',
    'color_analysis': 'Color Distribution',
    'sustainability': 'Sustainability Metrics',
    'recommendations': 'Recommendations',
    'insights': 'Insights & Tips',
  };

  final Map<String, IconData> _sectionIcons = {
    'overview': Icons.dashboard_outlined,
    'usage_stats': Icons.bar_chart_outlined,
    'category_analysis': Icons.category_outlined,
    'color_analysis': Icons.palette_outlined,
    'sustainability': Icons.eco_outlined,
    'recommendations': Icons.recommend_outlined,
    'insights': Icons.lightbulb_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedSections.values.where((v) => v).length;
    
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.download_outlined,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Analytics',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'Choose what to include in your export',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Format Selection
                    Text(
                      'Export Format',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormatOption('pdf', 'PDF Document', Icons.picture_as_pdf),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFormatOption('csv', 'CSV Data', Icons.table_chart),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Section Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Include Sections',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$selectedCount selected',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Select All / None buttons
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _selectedSections.updateAll((key, value) => true);
                          }),
                          icon: const Icon(Icons.check_box, size: 16),
                          label: const Text('Select All'),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _selectedSections.updateAll((key, value) => false);
                          }),
                          icon: const Icon(Icons.check_box_outline_blank, size: 16),
                          label: const Text('None'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Section checkboxes
                    ..._selectedSections.entries.map((entry) {
                      final key = entry.key;
                      final isSelected = entry.value;
                      final label = _sectionLabels[key]!;
                      final icon = _sectionIcons[key]!;
                      
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) => setState(() {
                          _selectedSections[key] = value ?? false;
                        }),
                        title: Text(
                          label,
                          style: context.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          _getSectionDescription(key),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        secondary: Icon(
                          icon,
                          color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: selectedCount > 0 ? () {
                        final selectedSectionsList = _selectedSections.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .toList();
                        
                        widget.onExport(selectedSectionsList, _selectedFormat);
                      } : null,
                      icon: const Icon(Icons.download),
                      label: Text('Export ($selectedCount sections)'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(String format, String label, IconData icon) {
    final isSelected = _selectedFormat == format;
    
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.1)
              : AppTheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.outline.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getSectionDescription(String key) {
    switch (key) {
      case 'overview':
        return 'Summary statistics and key metrics';
      case 'usage_stats':
        return 'Detailed usage patterns and frequency';
      case 'category_analysis':
        return 'Breakdown by clothing categories';
      case 'color_analysis':
        return 'Color distribution and preferences';
      case 'sustainability':
        return 'Environmental impact and efficiency';
      case 'recommendations':
        return 'Personalized suggestions and tips';
      case 'insights':
        return 'AI-generated insights and observations';
      default:
        return '';
    }
  }
}
