import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Botão de ação com gradiente
class GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool isOutlined;
  final double? width;

  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: isOutlined
                  ? null
                  : (backgroundColor != null
                        ? null
                        : (gradient ?? AppTheme.primaryGradient)),
              color: isOutlined ? null : backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: isOutlined
                  ? Border.all(color: AppTheme.primaryGold, width: 2)
                  : null,
              boxShadow: isOutlined
                  ? null
                  : [
                      BoxShadow(
                        color: (backgroundColor ?? AppTheme.primaryBlue)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isOutlined ? AppTheme.primaryGold : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: isOutlined ? AppTheme.primaryGold : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão de ação circular com ícone
class CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final String? tooltip;

  const CircleActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppTheme.primaryBlue,
    this.iconColor = Colors.white,
    this.size = 56,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: size * 0.45),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
