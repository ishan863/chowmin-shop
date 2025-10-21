import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/theme_provider.dart';

/// Animated Theme Toggle Widget
class ThemeToggleWidget extends StatefulWidget {
  final bool showLabel;
  final double size;

  const ThemeToggleWidget({
    Key? key,
    this.showLabel = true,
    this.size = 32.0,
  }) : super(key: key);

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme(ThemeProvider themeProvider) {
    _controller.forward().then((_) => _controller.reverse());
    themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () => _toggleTheme(themeProvider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: EdgeInsets.symmetric(
          horizontal: widget.showLabel ? 16 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.indigo, Colors.purple]
                : [Colors.orange, Colors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.purple : Colors.orange).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.white,
                      size: widget.size,
                    ),
                  ),
                );
              },
            ),
            if (widget.showLabel) ...[
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  isDark ? 'Dark' : 'Light',
                  key: ValueKey(isDark),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Theme Preview Card for Settings
class ThemePreviewCard extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTap;

  const ThemePreviewCard({
    Key? key,
    required this.isDarkMode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Theme Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.indigo, Colors.purple]
                        : [Colors.orange, Colors.amber],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),

              // Theme Name
              Text(
                isDarkMode ? 'Dark Mode' : 'Light Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                isDarkMode
                    ? 'Easy on the eyes'
                    : 'Bright and clear',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 12),

              // Preview Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPreviewBox(Colors.red),
                  const SizedBox(width: 8),
                  _buildPreviewBox(Colors.green),
                  const SizedBox(width: 8),
                  _buildPreviewBox(Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewBox(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Animated Theme Switch (iOS Style)
class AnimatedThemeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedThemeSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: value
                ? [Colors.indigo, Colors.purple]
                : [Colors.orange, Colors.amber],
          ),
          boxShadow: [
            BoxShadow(
              color: (value ? Colors.purple : Colors.orange).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icons
            Positioned(
              left: 8,
              top: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: value ? 0 : 1,
                child: const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: value ? 1 : 0,
                child: const Icon(
                  Icons.nightlight_round,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

            // Thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: value ? 32 : 4,
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
