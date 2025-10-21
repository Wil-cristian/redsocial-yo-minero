import 'package:flutter/material.dart';

/// Widget para mostrar un elemento del grid de opciones del dashboard
class DashboardGridItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isHighlighted;

  const DashboardGridItem({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.iconColor = const Color(0xFF6C63FF),
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<DashboardGridItem> createState() => _DashboardGridItemState();
}

class _DashboardGridItemState extends State<DashboardGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isHighlighted ? widget.iconColor : widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.isHighlighted
                    ? widget.iconColor.withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isHighlighted
                      ? Colors.white.withValues(alpha: 0.2)
                      : widget.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  size: 40,
                  color: widget.isHighlighted ? Colors.white : widget.iconColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.isHighlighted ? Colors.white : Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
