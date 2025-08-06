import 'package:flutter/material.dart';
import '../../features/social/domain/entities/user_profile.dart';

/// Online Status Indicator Widget
/// 
/// Displays a colored indicator based on user's online status.
class OnlineStatusIndicator extends StatelessWidget {
  final OnlineStatus status;
  final double size;

  const OnlineStatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }
  
  /// Get status color
  Color _getStatusColor(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return Colors.green;
      case OnlineStatus.away:
        return Colors.orange;
      case OnlineStatus.busy:
        return Colors.red;
      case OnlineStatus.offline:
        return Colors.grey;
    }
  }
}
