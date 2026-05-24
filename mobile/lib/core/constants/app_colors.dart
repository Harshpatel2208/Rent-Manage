import 'package:flutter/material.dart';

/// Premium dark-themed color palette for MoneyManager.
///
/// All colours are static const [Color] values for use across the app.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand / Primary
  // ---------------------------------------------------------------------------
  /// Deep indigo — primary brand colour.
  static const Color primary = Color(0xFF4F46E5);

  /// Lighter indigo — for hover/active states.
  static const Color primaryLight = Color(0xFF818CF8);

  /// Emerald — secondary accent.
  static const Color secondary = Color(0xFF10B981);

  /// Lighter emerald — for secondary hover/active.
  static const Color secondaryLight = Color(0xFF34D399);

  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------
  /// Deepest background layer.
  static const Color background = Color(0xFF0F0F1A);

  /// Elevated surface (cards, sheets).
  static const Color surface = Color(0xFF1A1A2E);

  /// Card background — slightly lighter than surface.
  static const Color card = Color(0xFF16213E);

  // ---------------------------------------------------------------------------
  // Semantic / Status
  // ---------------------------------------------------------------------------
  /// Error / danger.
  static const Color error = Color(0xFFEF4444);

  /// Strong danger (destructive actions).
  static const Color danger = Color(0xFFDC2626);

  /// Warning amber.
  static const Color warning = Color(0xFFF59E0B);

  /// Success green (same as secondary).
  static const Color success = Color(0xFF10B981);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------
  /// Primary text — near-white.
  static const Color textPrimary = Color(0xFFF1F5F9);

  /// Secondary text — muted slate.
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Hint / placeholder text.
  static const Color textHint = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // Borders / Dividers
  // ---------------------------------------------------------------------------
  /// Subtle border.
  static const Color border = Color(0xFF2D3748);

  /// Divider line.
  static const Color divider = Color(0xFF1E293B);

  // ---------------------------------------------------------------------------
  // Gradient helpers
  // ---------------------------------------------------------------------------
  /// Primary gradient (left→right).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF7C3AED)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Card gradient (top→bottom).
  static const LinearGradient cardGradient = LinearGradient(
    colors: [card, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success / income gradient.
  static const LinearGradient successGradient = LinearGradient(
    colors: [secondary, Color(0xFF059669)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ---------------------------------------------------------------------------
  // Status badge colours (background / foreground pairs)
  // ---------------------------------------------------------------------------
  static const Color statusActiveBg = Color(0xFF064E3B);
  static const Color statusActiveFg = Color(0xFF34D399);
  static const Color statusClosedBg = Color(0xFF1E293B);
  static const Color statusClosedFg = Color(0xFF94A3B8);
  static const Color statusPendingBg = Color(0xFF7F1D1D);
  static const Color statusPendingFg = Color(0xFFFCA5A5);
  static const Color statusPartialBg = Color(0xFF78350F);
  static const Color statusPartialFg = Color(0xFFFCD34D);
  static const Color statusPaidBg = Color(0xFF064E3B);
  static const Color statusPaidFg = Color(0xFF34D399);
}
