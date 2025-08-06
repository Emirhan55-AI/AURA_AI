import 'package:flutter/material.dart';
import '../../../../controllers/style_discovery_controller.dart';

/// TinderCard - Swipeable card interface for style preferences
/// 
/// Provides a Tinder-like interface where users can swipe left/right
/// or tap buttons to indicate preferences for style options.
class TinderCard extends StatefulWidget {
  final StyleQuestion question;
  final StyleAnswer? currentAnswer;
  final void Function(List<String>) onAnswer;

  const TinderCard({
    super.key,
    required this.question,
    required this.currentAnswer,
    required this.onAnswer,
  });

  @override
  State<TinderCard> createState() => _TinderCardState();
}

class _TinderCardState extends State<TinderCard> with TickerProviderStateMixin {
  late final AnimationController _cardController;
  late final AnimationController _overlayController;
  late final Animation<double> _overlayAnimation;
  
  int _currentOptionIndex = 0;
  final List<String> _likedOptions = [];
  final List<String> _dislikedOptions = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));

    // Initialize from current answer if exists
    if (widget.currentAnswer?.type == AnswerType.list && widget.currentAnswer?.value != null) {
      if (widget.currentAnswer!.value is List) {
        _likedOptions.addAll((widget.currentAnswer!.value as List).map((e) => e.toString()));
      }
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final options = widget.question.options ?? <String>[];
    if (_currentOptionIndex >= options.length) {
      return _buildCompletionCard(theme, colorScheme);
    }

    return Column(
      children: [
        // Question title
        _buildQuestionTitle(theme, colorScheme),
        
        const SizedBox(height: 32),
        
        // Card stack
        Expanded(
          child: _buildCardStack(theme, colorScheme),
        ),
        
        const SizedBox(height: 32),
        
        // Action buttons
        _buildActionButtons(theme, colorScheme),
        
        const SizedBox(height: 16),
        
        // Progress indicator
        _buildProgressIndicator(theme, colorScheme),
      ],
    );
  }

  Widget _buildQuestionTitle(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            widget.question.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.question.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardStack(ThemeData theme, ColorScheme colorScheme) {
    return Stack(
      children: [
        // Background cards (next options preview)
        for (int i = _currentOptionIndex + 1; 
             i < _currentOptionIndex + 3 && i < (widget.question.options?.length ?? 0); 
             i++)
          _buildBackgroundCard(i, theme, colorScheme),
        
        // Current card
        _buildCurrentCard(theme, colorScheme),
      ].reversed.toList(),
    );
  }

  Widget _buildBackgroundCard(int index, ThemeData theme, ColorScheme colorScheme) {
    final offset = (index - _currentOptionIndex) * 8.0;
    final scale = 1.0 - (index - _currentOptionIndex) * 0.02;
    
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(0, offset),
        child: Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCard(ThemeData theme, ColorScheme colorScheme) {
    if (widget.question.options == null) return _buildCompletionCard(theme, colorScheme);
    final currentOption = widget.question.options![_currentOptionIndex];
    
    return GestureDetector(
      onPanUpdate: (details) {
        if (!_isAnimating) {
          setState(() {
            _cardController.value += details.delta.dx / 300;
          });
          
          // Update overlay based on pan direction
          if (details.delta.dx > 0) {
            _overlayController.forward();
          } else if (details.delta.dx < 0) {
            _overlayController.forward();
          }
        }
      },
      onPanEnd: (details) {
        if (!_isAnimating) {
          if (_cardController.value > 0.3) {
            _likeCurrentOption();
          } else if (_cardController.value < -0.3) {
            _dislikeCurrentOption();
          } else {
            _resetCard();
          }
        }
      },
      child: AnimatedBuilder(
        animation: _cardController,
        builder: (context, child) {
          final rotationAngle = _cardController.value * 0.3;
          final slideOffset = _cardController.value * 300;
          
          return Transform.translate(
            offset: Offset(slideOffset, 0),
            child: Transform.rotate(
              angle: rotationAngle,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Card content
                    _buildCardContent(currentOption, theme, colorScheme),
                    
                    // Overlay for like/dislike
                    _buildCardOverlay(theme, colorScheme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(String option, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Option image placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.style,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Option text
          Text(
            option,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardOverlay(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        final isLike = _cardController.value > 0;
        final opacity = _overlayAnimation.value * 0.8;
        
        if (_cardController.value.abs() < 0.1) return const SizedBox();
        
        return Container(
          decoration: BoxDecoration(
            color: (isLike ? Colors.green : Colors.red).withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                isLike ? 'LOVE IT!' : 'NOT FOR ME',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isLike ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Dislike button
        FloatingActionButton(
          onPressed: _isAnimating ? null : _dislikeCurrentOption,
          backgroundColor: Colors.red.shade100,
          heroTag: 'dislike',
          child: Icon(
            Icons.close,
            color: Colors.red.shade700,
            size: 28,
          ),
        ),
        
        // Like button
        FloatingActionButton(
          onPressed: _isAnimating ? null : _likeCurrentOption,
          backgroundColor: Colors.green.shade100,
          heroTag: 'like',
          child: Icon(
            Icons.favorite,
            color: Colors.green.shade700,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, ColorScheme colorScheme) {
    final progress = (_currentOptionIndex + 1) / (widget.question.options?.length ?? 1);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentOptionIndex + 1}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${widget.question.options?.length ?? 0}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 50,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Great choices! ✨',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'You selected ${_likedOptions.length} style${_likedOptions.length != 1 ? 's' : ''} that match your taste.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _likeCurrentOption() {
    if (_isAnimating) return;
    if (widget.question.options == null) return;
    
    _isAnimating = true;
    final currentOption = widget.question.options![_currentOptionIndex];
    
    setState(() {
      _likedOptions.add(currentOption);
    });
    
    _cardController.forward().then((_) {
      _nextOption();
    });
  }

  void _dislikeCurrentOption() {
    if (_isAnimating) return;
    if (widget.question.options == null) return;
    
    _isAnimating = true;
    final currentOption = widget.question.options![_currentOptionIndex];
    
    setState(() {
      _dislikedOptions.add(currentOption);
    });
    
    _cardController.reverse().then((_) {
      _nextOption();
    });
  }

  void _nextOption() {
    setState(() {
      _currentOptionIndex++;
      _isAnimating = false;
    });
    
    _cardController.reset();
    _overlayController.reset();
    
    // Update answer
    widget.onAnswer(_likedOptions);
  }

  void _resetCard() {
    _cardController.animateTo(0.0);
    _overlayController.reverse();
  }
}
