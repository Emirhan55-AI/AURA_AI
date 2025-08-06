import 'package:flutter/material.dart';

/// Custom app bar for messaging screen
class MessagingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final int unreadCount;
  final VoidCallback onSearchToggle;
  final VoidCallback onClearSearch;

  const MessagingAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.unreadCount,
    required this.onSearchToggle,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onSearchToggle,
        ),
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search conversations...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClearSearch,
            ),
        ],
      );
    }

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Messages'),
          if (unreadCount > 0)
            Text(
              '$unreadCount unread',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchToggle,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_all_read':
                // TODO: Implement mark all as read
                break;
              case 'archived':
                // TODO: Navigate to archived conversations
                break;
              case 'settings':
                // TODO: Navigate to messaging settings
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  Icon(Icons.mark_email_read),
                  SizedBox(width: 8),
                  Text('Mark all as read'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'archived',
              child: Row(
                children: [
                  Icon(Icons.archive),
                  SizedBox(width: 8),
                  Text('Archived chats'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
