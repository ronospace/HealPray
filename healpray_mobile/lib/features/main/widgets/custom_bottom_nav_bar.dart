import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/app_shell.dart';

/// Custom bottom navigation bar with spiritual theming and rotating animations
class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<NavigationItem> items;
  final Function(int) onTap;

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _rotationControllers;
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _rotationAnimations;
  late List<Animation<double>> _scaleAnimations;
  int? _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    // Create animation controllers for each nav item
    _rotationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _scaleControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    // Create rotation animations (0 to 360 degrees)
    _rotationAnimations = _rotationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    // Create scale animations (pulse effect)
    _scaleAnimations = _scaleControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Animate the initially selected item
    _scaleControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      // Animate the newly selected item
      _rotationControllers[widget.currentIndex].forward(from: 0.0);
      _scaleControllers[widget.currentIndex].forward();

      // Reverse animation for previously selected item
      if (_previousIndex != null && _previousIndex != widget.currentIndex) {
        _scaleControllers[_previousIndex!].reverse();
      }

      _previousIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    for (var controller in _rotationControllers) {
      controller.dispose();
    }
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.healingTeal.withOpacity(0.02),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.healingTeal.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _rotationAnimations[index],
            _scaleAnimations[index],
          ]),
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with rotation and scale animations
                Transform.scale(
                  scale: isSelected ? _scaleAnimations[index].value : 1.0,
                  child: Transform.rotate(
                    angle: isSelected ? _rotationAnimations[index].value : 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.healingTeal.withOpacity(0.15),
                                  AppTheme.healingBlue.withOpacity(0.15),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.healingTeal.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected
                            ? AppTheme.healingTeal
                            : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Label with fade animation
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppTheme.healingTeal : Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Active indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(top: 4),
                  width: isSelected ? 6 : 0,
                  height: isSelected ? 6 : 0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.healingTeal,
                        AppTheme.healingBlue,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.healingTeal.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
