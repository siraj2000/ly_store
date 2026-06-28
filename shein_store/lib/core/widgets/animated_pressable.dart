import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_motion.dart';

class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.scale = 0.97,
    this.haptic = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _pressed && !AppMotion.reduceMotion(context) ? widget.scale : 1,
      duration: AppMotion.duration(context, AppMotion.fast),
      curve: AppMotion.standard,
      child: widget.child,
    );

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) {
                  HapticFeedback.lightImpact();
                }
                widget.onTap!();
              },
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: child,
        ),
      ),
    );
  }
}
