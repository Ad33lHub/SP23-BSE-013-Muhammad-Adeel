import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/glassmorphism_theme.dart';

/// Glass Card Widget with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.border,
    this.boxShadow,
    this.blur = glassBlur,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(glassRadius),
        border: border ??
            Border.all(
              color: GlassmorphismTheme.glassWhite.withOpacity(0.2),
              width: 1.5,
            ),
        boxShadow: boxShadow ?? glassShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(glassRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GlassmorphismTheme.glassWhite.withOpacity(glassOpacity),
                  GlassmorphismTheme.glassWhite.withOpacity(glassOpacity * 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(glassRadius),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(glassRadius),
        child: widget,
      );
    }

    return widget;
  }
}

/// Glass Button with gradient and glow effect
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool isLoading;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.width,
    this.height,
    this.isLoading = false,
    this.gradient,
    this.boxShadow,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
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

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(glassRadius),
            gradient: widget.gradient ?? GlassmorphismTheme.primaryGradient,
            boxShadow: widget.boxShadow ?? [
              ...glassShadow,
              BoxShadow(
                color: GlassmorphismTheme.neonBlue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
            border: Border.all(
              color: GlassmorphismTheme.glassWhite.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}

/// Glass Container with custom styling
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? color;
  final double opacity;
  final double blur;
  final BorderRadius? borderRadius;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.opacity = glassOpacity,
    this.blur = glassBlur,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(glassRadius),
        border: border ??
            Border.all(
              color: GlassmorphismTheme.glassWhite.withOpacity(0.2),
              width: 1.5,
            ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(glassRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? GlassmorphismTheme.glassWhite)
                  .withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(glassRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass Background with gradient
class GlassBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;

  const GlassBackground({
    super.key,
    required this.child,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? [
            GlassmorphismTheme.darkBackground,
            const Color(0xFF1A1F3A),
            const Color(0xFF0F1429),
            GlassmorphismTheme.darkBackground,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Neon Glow Text
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Color glowColor;
  final double glowRadius;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.white,
    this.glowColor = GlassmorphismTheme.neonBlue,
    this.glowRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        shadows: [
          Shadow(
            color: glowColor,
            blurRadius: glowRadius,
          ),
          Shadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: glowRadius * 2,
          ),
        ],
      ),
    );
  }
}

/// Animated Glass Card
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GlassCard(
          padding: widget.padding,
          margin: widget.margin,
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}

