import 'package:flutter/material.dart';

/// FavoritesMultiSelectToolbar - Toolbar for multi-select operations
/// 
/// This widget appears when the user enters multi-select mode,
/// offering actions like remove, share, and select all for favorited items.
class FavoritesMultiSelectToolbar extends StatefulWidget {
  final bool isVisible;
  final int selectedCount;
  final int totalCount;
  final void Function()? onSelectAll;
  final void Function()? onDeselectAll;
  final void Function()? onRemoveSelected;
  final void Function()? onShareSelected;
  final void Function()? onCancel;

  const FavoritesMultiSelectToolbar({
    super.key,
    required this.isVisible,
    required this.selectedCount,
    required this.totalCount,
    this.onSelectAll,
    this.onDeselectAll,
    this.onRemoveSelected,
    this.onShareSelected,
    this.onCancel,
  });

  @override
  State<FavoritesMultiSelectToolbar> createState() => _FavoritesMultiSelectToolbarState();
}

class _FavoritesMultiSelectToolbarState extends State<FavoritesMultiSelectToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(FavoritesMultiSelectToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 80),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Cancel button
                    IconButton(
                      onPressed: widget.onCancel,
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      tooltip: 'Cancel',
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Selected count
                    Expanded(
                      child: Text(
                        '${widget.selectedCount} selected',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Select/Deselect all button
                    TextButton(
                      onPressed: widget.selectedCount == widget.totalCount
                          ? widget.onDeselectAll
                          : widget.onSelectAll,
                      child: Text(
                        widget.selectedCount == widget.totalCount
                            ? 'Deselect All'
                            : 'Select All',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Share button
                    IconButton(
                      onPressed: widget.selectedCount > 0 ? widget.onShareSelected : null,
                      icon: Icon(
                        Icons.share,
                        color: widget.selectedCount > 0
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onPrimaryContainer.withOpacity(0.5),
                      ),
                      tooltip: 'Share',
                    ),
                    
                    // Remove button
                    IconButton(
                      onPressed: widget.selectedCount > 0 ? widget.onRemoveSelected : null,
                      icon: Icon(
                        Icons.delete,
                        color: widget.selectedCount > 0
                            ? colorScheme.error
                            : colorScheme.error.withOpacity(0.5),
                      ),
                      tooltip: 'Remove from favorites',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
