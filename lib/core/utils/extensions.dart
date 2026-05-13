import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── DateTime Extensions ─────────────────────────────────────────────────────

extension DateTimeExtensions on DateTime {
  String toDateString([String format = 'MMM dd, yyyy']) {
    return DateFormat(format).format(this);
  }

  String toTimeString([String format = 'hh:mm a']) {
    return DateFormat(format).format(this);
  }

  String toDateTimeString([String format = 'MMM dd, yyyy hh:mm a']) {
    return DateFormat(format).format(this);
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

// ── String Extensions ──────────────────────────────────────────────────────

extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty;

  bool get isNotNullOrNotEmpty => isNotEmpty;

  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get capitalizeAll {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength) + suffix;
  }
}

// ── BuildContext Extensions ─────────────────────────────────────────────────

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isKeyboardOpen => mediaQuery.viewInsets.bottom > 0;

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
