import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? subtleBackground;
  final Color? criticalStock;
  final Color? warningStock;
  final Color? healthyStock;
  final Color? surfaceGradientStart;
  final Color? surfaceGradientEnd;

  const AppThemeExtension({
    this.subtleBackground,
    this.criticalStock,
    this.warningStock,
    this.healthyStock,
    this.surfaceGradientStart,
    this.surfaceGradientEnd,
  });

  @override
  AppThemeExtension copyWith({
    Color? subtleBackground,
    Color? criticalStock,
    Color? warningStock,
    Color? healthyStock,
    Color? surfaceGradientStart,
    Color? surfaceGradientEnd,
  }) {
    return AppThemeExtension(
      subtleBackground: subtleBackground ?? this.subtleBackground,
      criticalStock: criticalStock ?? this.criticalStock,
      warningStock: warningStock ?? this.warningStock,
      healthyStock: healthyStock ?? this.healthyStock,
      surfaceGradientStart: surfaceGradientStart ?? this.surfaceGradientStart,
      surfaceGradientEnd: surfaceGradientEnd ?? this.surfaceGradientEnd,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      subtleBackground: Color.lerp(subtleBackground, other.subtleBackground, t),
      criticalStock: Color.lerp(criticalStock, other.criticalStock, t),
      warningStock: Color.lerp(warningStock, other.warningStock, t),
      healthyStock: Color.lerp(healthyStock, other.healthyStock, t),
      surfaceGradientStart: Color.lerp(
        surfaceGradientStart,
        other.surfaceGradientStart,
        t,
      ),
      surfaceGradientEnd: Color.lerp(
        surfaceGradientEnd,
        other.surfaceGradientEnd,
        t,
      ),
    );
  }
}
