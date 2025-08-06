import 'package:flutter/material.dart';

/// Connection status banner for real-time messaging
class ConnectionStatusBanner extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onRetry;

  const ConnectionStatusBanner({
    super.key,
    required this.isConnected,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            size: 16,
            color: Colors.orange.shade700,
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: Text(
              'Connection lost. Messages may not be delivered.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
