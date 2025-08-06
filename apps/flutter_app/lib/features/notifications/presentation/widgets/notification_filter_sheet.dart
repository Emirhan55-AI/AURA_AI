import 'package:flutter/material.dart';
import '../../domain/entities/app_notification.dart';

class NotificationFilterSheet extends StatefulWidget {
  final Set<NotificationType> selectedTypes;
  final Function(Set<NotificationType>) onFiltersChanged;

  const NotificationFilterSheet({
    super.key,
    required this.selectedTypes,
    required this.onFiltersChanged,
  });

  @override
  State<NotificationFilterSheet> createState() => _NotificationFilterSheetState();
}

class _NotificationFilterSheetState extends State<NotificationFilterSheet> {
  late Set<NotificationType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Notifications',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTypes.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...NotificationType.values.map((type) => CheckboxListTile(
            title: Text(_getTypeDisplayName(type)),
            subtitle: Text(_getTypeDescription(type)),
            value: _selectedTypes.contains(type),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedTypes.add(type);
                } else {
                  _selectedTypes.remove(type);
                }
              });
            },
          )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onFiltersChanged(_selectedTypes);
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.social:
        return 'Social';
      case NotificationType.system:
        return 'System';
      case NotificationType.swap:
        return 'Swap Market';
      case NotificationType.wardrobe:
        return 'Wardrobe';
      case NotificationType.challenge:
        return 'Style Challenges';
      case NotificationType.message:
        return 'Messages';
    }
  }

  String _getTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.social:
        return 'Likes, comments, and follows';
      case NotificationType.system:
        return 'App updates and announcements';
      case NotificationType.swap:
        return 'Swap requests and matches';
      case NotificationType.wardrobe:
        return 'Outfit suggestions and reminders';
      case NotificationType.challenge:
        return 'Style challenges and competitions';
      case NotificationType.message:
        return 'Direct messages and chats';
    }
  }
}
