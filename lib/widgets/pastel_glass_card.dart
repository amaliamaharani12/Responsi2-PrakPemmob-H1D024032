import 'package:flutter/material.dart';

/// Soft frosted pastel card used consistently across Home and Search screens.
class PastelGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const PastelGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? Colors.white.withValues(alpha: 0.78) : null,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.85),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF9AC3EC).withValues(alpha: 0.18),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: decoration,
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}
