import 'package:flutter/material.dart';

/// Theme-aware color extensions to help with dark mode compatibility
extension ThemeAwareColors on BuildContext {
  /// Returns true if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Returns the appropriate card color for current theme
  Color get cardColor => Theme.of(this).cardColor;

  /// Returns the appropriate background color for current theme
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Returns theme-aware divider color
  Color get dividerColor => Theme.of(this).dividerColor;

  /// Returns theme-aware text color (primary)
  Color get textColor =>
      Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;

  /// Returns theme-aware secondary text color
  Color get textSecondaryColor =>
      Theme.of(this).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
      Colors.grey;

  /// Returns theme-aware hint text color
  Color get hintColor =>
      Theme.of(this).textTheme.bodySmall?.color?.withValues(alpha: 0.5) ??
      Colors.grey.shade600;

  /// Returns theme-aware border color
  Color get borderColor {
    if (isDarkMode) {
      return Colors.white.withValues(alpha: 0.1);
    }
    return Colors.grey.withValues(alpha: 0.15);
  }

  /// Returns theme-aware shadow color
  Color get shadowColor {
    if (isDarkMode) {
      return Colors.black.withValues(alpha: 0.3);
    }
    return Colors.black.withValues(alpha: 0.04);
  }

  /// Returns theme-aware subtle background color (for containers)
  Color get subtleBackgroundColor {
    if (isDarkMode) {
      return Colors.white.withValues(alpha: 0.05);
    }
    return Colors.black.withValues(alpha: 0.02);
  }

  /// Returns theme-aware icon color
  Color get iconColor =>
      Theme.of(this).iconTheme.color ??
      Theme.of(this).textTheme.bodyMedium?.color ??
      Colors.grey;

  /// Returns theme-aware disabled color
  Color get disabledColor => Theme.of(this).disabledColor;
}
