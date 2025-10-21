import 'package:flutter/material.dart';

/// Badge widget para mostrar contador en iconos
class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showBadge;

  const BadgeIcon({
    super.key,
    required this.icon,
    this.count = 0,
    this.backgroundColor = const Color(0xFF6C63FF),
    this.iconColor = const Color(0xFF6C63FF),
    required this.onTap,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, size: 20),
          onPressed: onTap,
        ),
        if (showBadge && count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
