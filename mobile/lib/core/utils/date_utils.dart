import 'package:intl/intl.dart';

/// Date utility functions used throughout the app.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _monthYearFmt = DateFormat('MMMM yyyy', 'en_IN');
  static final DateFormat _dateFmt = DateFormat('MMM dd, yyyy', 'en_IN');
  static final DateFormat _shortDateFmt = DateFormat('dd/MM/yyyy', 'en_IN');

  // ---------------------------------------------------------------------------
  // Cycle helpers
  // ---------------------------------------------------------------------------

  /// Returns the 1st day of the month following [date].
  ///
  /// Example: `2026-05-15` → `2026-06-01`
  static DateTime getFirstOfNextMonth(DateTime date) {
    final nextMonth = date.month == 12 ? 1 : date.month + 1;
    final nextYear = date.month == 12 ? date.year + 1 : date.year;
    return DateTime(nextYear, nextMonth, 1);
  }

  /// Returns the 1st day of the current month (today's cycle month).
  static DateTime getCurrentCycleMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Returns the 1st day of [date]'s month.
  static DateTime firstOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  // ---------------------------------------------------------------------------
  // Formatters
  // ---------------------------------------------------------------------------

  /// Formats [date] as `'May 2026'`.
  static String formatMonthYear(DateTime date) =>
      _monthYearFmt.format(date);

  /// Formats [date] as `'May 21, 2026'`.
  static String formatDate(DateTime date) => _dateFmt.format(date);

  /// Formats [date] as `'21/05/2026'`.
  static String formatShort(DateTime date) => _shortDateFmt.format(date);

  /// Returns `true` if [date] is in the current calendar month.
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Returns a human-readable relative label: 'Today', 'Yesterday', or
  /// the formatted date string.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return formatDate(date);
  }

  /// Generates a list of the first day of each month from [start] to [end]
  /// inclusive (useful for building interest schedule timelines).
  static List<DateTime> monthRange(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = firstOfMonth(start);
    final last = firstOfMonth(end);
    while (!current.isAfter(last)) {
      months.add(current);
      current = getFirstOfNextMonth(current);
    }
    return months;
  }
}
