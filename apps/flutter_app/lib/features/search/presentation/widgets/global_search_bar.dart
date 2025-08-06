import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/global_search_controller.dart';

class GlobalSearchBar extends ConsumerStatefulWidget {
  final String? hintText;
  final bool autofocus;
  final VoidCallback? onClear;

  const GlobalSearchBar({
    super.key,
    this.hintText,
    this.autofocus = true,
    this.onClear,
  });

  @override
  ConsumerState<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends ConsumerState<GlobalSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(globalSearchControllerProvider);
    final searchController = ref.watch(globalSearchControllerProvider.notifier);

    // Update controller text if search term changes externally
    if (_controller.text != searchState.searchTerm) {
      _controller.text = searchState.searchTerm;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _focusNode.hasFocus 
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search clothing, outfits, users...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              onChanged: (value) {
                searchController.updateSearchTerm(value);
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  searchController.search(value.trim());
                }
              },
            ),
          ),
          // Loading indicator or clear button
          if (searchState.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else if (searchState.searchTerm.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                searchController.clearSearch();
                widget.onClear?.call();
              },
              icon: Icon(
                Icons.clear,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              tooltip: 'Clear search',
            ),
        ],
      ),
    );
  }
}
