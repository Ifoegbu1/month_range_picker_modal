import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../month_range_picker.dart';

/// Duration presets for date range selection.
enum DateRangeDuration { last3Months, last6Months, custom }

/// A widget for selecting custom date ranges with preset options.
class CustomDateRange extends StatefulWidget {
  /// Whether to show all months regardless of restrictions.
  final bool showAllMonths;

  /// Callback when date range changes.
  final Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  /// Initial date range to display.
  final DateTimeRange? initialDateTimeRange;

  /// Primary color for selected items. If null, uses Theme.of(context).colorScheme.primary.
  final Color? primaryColor;

  /// Color for unselected text. If null, uses Theme.of(context).textTheme.bodyMedium?.color with opacity.
  final Color? unselectedTextColor;

  /// Text style for date field labels and values. If null, uses Theme.of(context).textTheme.bodyLarge.
  final TextStyle? dateTextStyle;

  /// Text style for info/label text. If null, uses Theme.of(context).textTheme.bodyMedium.
  final TextStyle? labelTextStyle;

  /// Text style for error messages. If null, uses Theme.of(context).textTheme.bodyMedium with red color.
  final TextStyle? errorTextStyle;

  /// Global font family that applies across all text. This will be merged into all TextStyles if provided.
  final String? fontFamily;

  /// Maximum allowed range in months. If null and [maxRangeYears] is also null, no limit is applied.
  /// If [maxRangeYears] is provided, this parameter is ignored.
  final int? maxRangeMonths;

  /// Maximum allowed range in years. If provided, takes precedence over [maxRangeMonths].
  /// For example, 1 year = 12 months, 2 years = 24 months.
  /// If both [maxRangeYears] and [maxRangeMonths] are null, no limit is applied.
  final int? maxRangeYears;

  /// Callback for showing validation errors. If null, uses a default inline error display.
  final void Function(BuildContext context, String message)? onValidationError;

  const CustomDateRange({
    super.key,
    this.onDateRangeChanged,
    required this.showAllMonths,
    this.initialDateTimeRange,
    this.primaryColor,
    this.unselectedTextColor,
    this.dateTextStyle,
    this.labelTextStyle,
    this.errorTextStyle,
    this.fontFamily,
    this.maxRangeMonths,
    this.maxRangeYears,
    this.onValidationError,
  });

  @override
  State<CustomDateRange> createState() => CustomDateRangeState();
}

class CustomDateRangeState extends State<CustomDateRange>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateRangeDuration _selectedDuration = DateRangeDuration.last3Months;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _errorMessage;

  /// Public getter for the start date.
  DateTime? get startDate => _startDate;

  /// Public getter for the end date.
  DateTime? get endDate => _endDate;

  /// Resets the date range to default values (Last 3 months).
  void reset() {
    setState(() {
      _selectedDuration = DateRangeDuration.last3Months;
      _errorMessage = null;
    });
    _setDateRangeForDuration(DateRangeDuration.last3Months);
  }

  Color get _primaryColor =>
      widget.primaryColor ?? Theme.of(context).colorScheme.primary;

  Color get _unselectedTextColor =>
      widget.unselectedTextColor ??
      (Theme.of(context).textTheme.bodyMedium?.color ??
          Colors.grey.withValues(alpha: 0.6));

  /// Merges fontFamily into a TextStyle if fontFamily is provided
  TextStyle _mergeFontFamily(TextStyle style) {
    if (widget.fontFamily != null) {
      return style.copyWith(fontFamily: widget.fontFamily);
    }
    return style;
  }

  TextStyle get _dateTextStyle {
    final baseStyle = widget.dateTextStyle ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16) ??
        const TextStyle(fontSize: 16);
    return _mergeFontFamily(baseStyle);
  }

  TextStyle get _labelTextStyle {
    final baseStyle = widget.labelTextStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16) ??
        const TextStyle(fontSize: 16);
    return _mergeFontFamily(baseStyle);
  }

  TextStyle get _errorTextStyle {
    final baseStyle = widget.errorTextStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.red.shade700,
            ) ??
        TextStyle(fontSize: 14, color: Colors.red.shade700);
    return _mergeFontFamily(baseStyle);
  }

  Color get _borderColor => Theme.of(context).dividerColor;

  /// Gets the maximum allowed range in months.
  /// If [maxRangeYears] is provided, converts it to months.
  /// Otherwise uses [maxRangeMonths].
  /// Returns null if no limit is set (both parameters are null).
  int? get _maxRangeMonths {
    if (widget.maxRangeYears != null) {
      return widget.maxRangeYears! * 12;
    }
    return widget.maxRangeMonths;
  }

  /// Checks if there's a range limit set.
  bool get _hasRangeLimit => _maxRangeMonths != null;

  /// Formats the maximum range limit as a human-readable string.
  /// Returns null if no limit is set.
  String? get _maxRangeText {
    if (!_hasRangeLimit) return null;

    if (widget.maxRangeYears != null) {
      final years = widget.maxRangeYears!;
      return years == 1 ? '1 year' : '$years years';
    }
    final months = widget.maxRangeMonths!;
    if (months >= 12 && months % 12 == 0) {
      final years = months ~/ 12;
      return years == 1 ? '1 year' : '$years years';
    }
    return months == 1 ? '1 month' : '$months months';
  }

  /// Detects which duration matches the provided date range.
  /// Returns null if no preset duration matches (i.e., it's a custom range).
  DateRangeDuration? _detectDurationFromRange(DateTimeRange range) {
    // Calculate the month difference between start and end
    final startMonth = range.start.month;
    final startYear = range.start.year;
    final endMonth = range.end.month;
    final endYear = range.end.year;

    final monthDifference =
        (endYear - startYear) * 12 + (endMonth - startMonth);

    // "Last 3 months" should have a 3-month span
    // "Last 6 months" should have a 6-month span
    // We allow some flexibility - the exact pattern is:
    // - Start month is exactly 3 months before end month (for 3 months)
    // - Start month is exactly 6 months before end month (for 6 months)

    if (monthDifference == 3) {
      // Verify that start month is exactly 3 months before end month
      // This handles year boundaries correctly
      final calculatedStartMonth = endMonth - 3;
      final calculatedStartYear = endYear;

      // Adjust for negative months (year boundary)
      final actualStartMonth = calculatedStartMonth <= 0
          ? calculatedStartMonth + 12
          : calculatedStartMonth;
      final actualStartYear = calculatedStartMonth <= 0
          ? calculatedStartYear - 1
          : calculatedStartYear;

      if (startMonth == actualStartMonth && startYear == actualStartYear) {
        return DateRangeDuration.last3Months;
      }
    }

    if (monthDifference == 6) {
      // Verify that start month is exactly 6 months before end month
      final calculatedStartMonth = endMonth - 6;
      final calculatedStartYear = endYear;

      // Adjust for negative months (year boundary)
      final actualStartMonth = calculatedStartMonth <= 0
          ? calculatedStartMonth + 12
          : calculatedStartMonth;
      final actualStartYear = calculatedStartMonth <= 0
          ? calculatedStartYear - 1
          : calculatedStartYear;

      if (startMonth == actualStartMonth && startYear == actualStartYear) {
        return DateRangeDuration.last6Months;
      }
    }

    // Doesn't match any preset duration
    return null;
  }

  @override
  void initState() {
    super.initState();

    // If initial date range is provided, detect the matching duration
    if (widget.initialDateTimeRange != null) {
      final detectedDuration = _detectDurationFromRange(
        widget.initialDateTimeRange!,
      );

      if (detectedDuration != null) {
        // Matches a preset duration - set the duration but preserve the original dates
        setState(() {
          _selectedDuration = detectedDuration;
          _startDate = widget.initialDateTimeRange!.start;
          _endDate = widget.initialDateTimeRange!.end;
        });
        widget.onDateRangeChanged?.call(_startDate!, _endDate!);
      } else {
        // Custom range - set the dates directly
        setState(() {
          _selectedDuration = DateRangeDuration.custom;
          _startDate = widget.initialDateTimeRange!.start;
          _endDate = widget.initialDateTimeRange!.end;
        });
        widget.onDateRangeChanged?.call(_startDate!, _endDate!);
      }
    } else {
      // No initial range provided, default to Last 3 months
      _setDateRangeForDuration(DateRangeDuration.last3Months);
    }
  }

  void _setDateRangeForDuration(DateRangeDuration duration) {
    final now = DateTime.now();
    setState(() {
      _selectedDuration = duration;
      switch (duration) {
        case DateRangeDuration.last3Months:
          _startDate = DateTime(now.year, now.month - 3);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case DateRangeDuration.last6Months:
          _startDate = DateTime(now.year, now.month - 6);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case DateRangeDuration.custom:
          // Keep current dates or set defaults
          _startDate ??= DateTime(now.year, now.month - 3);
          _endDate ??= now;
          break;
      }
      // Clear any previous error when user selects a preset duration
      _errorMessage = null;
      widget.onDateRangeChanged?.call(_startDate!, _endDate!);
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  bool _isValidDateRange(DateTime start, DateTime end) {
    // If no limit is set, always return true
    if (!_hasRangeLimit) return true;

    // Calculate the difference in months
    final monthsDifference =
        (end.year - start.year) * 12 + (end.month - start.month);
    return monthsDifference <= _maxRangeMonths!;
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final result = await MonthRangePicker.show(
      context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      showTabs: false,
      showAllMonths: widget.showAllMonths,
      headerText: isStartDate ? 'Select start date' : 'Select end date',
      primaryColor: _primaryColor,
      unselectedTextColor: _unselectedTextColor,
      dateTextStyle: _dateTextStyle,
      labelTextStyle: _labelTextStyle,
      errorTextStyle: _errorTextStyle,
      fontFamily: widget.fontFamily,
      onValidationError: widget.onValidationError,
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;

      if (selectedDate != null && actionType == ActionType.confirm) {
        // Update the state without validation - validation happens on main confirm
        setState(() {
          if (isStartDate) {
            _startDate = selectedDate;
          } else {
            _endDate = selectedDate;
          }
          _selectedDuration = DateRangeDuration.custom;
          // Clear any previous error when user selects a date
          _errorMessage = null;
        });
      }
    }
  }

  /// Validates the date range and shows error messages if validation fails.
  /// Returns true if validation passes, false otherwise.
  bool validateAndNotify({
    void Function(BuildContext context, String message)? onValidationError,
  }) {
    String? errorMessage;

    if (_startDate == null || _endDate == null) {
      const message = 'Please select both start and end dates.';
      errorMessage = message;
      if (onValidationError != null) {
        onValidationError(context, message);
      }
    } else if (_startDate!.isAfter(_endDate!)) {
      // Check if start date is after end date
      const message =
          'Start date cannot be after end date. Please adjust your dates.';
      errorMessage = message;
      if (onValidationError != null) {
        onValidationError(context, message);
      }
    } else if (!_isValidDateRange(_startDate!, _endDate!)) {
      // Validate the date range doesn't exceed the maximum allowed range
      if (_hasRangeLimit && _maxRangeText != null) {
        final message =
            'Custom range cannot exceed $_maxRangeText. Please select a shorter duration.';
        errorMessage = message;
        if (onValidationError != null) {
          onValidationError(context, message);
        }
      }
    }

    // Show error message inline if validation failed
    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
      });
      return false;
    }

    // All validations passed - clear any previous error
    setState(() {
      _errorMessage = null;
    });
    widget.onDateRangeChanged?.call(_startDate!, _endDate!);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration label
          Text(
            'Duration',
            style: _labelTextStyle,
          ),
          const Gap(12),

          // Duration chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 12,
              children: [
                _DurationChip(
                  label: 'Last 3 months',
                  isSelected:
                      _selectedDuration == DateRangeDuration.last3Months,
                  onTap: () =>
                      _setDateRangeForDuration(DateRangeDuration.last3Months),
                  primaryColor: _primaryColor,
                  unselectedTextColor: _unselectedTextColor,
                  labelTextStyle: _labelTextStyle,
                ),
                _DurationChip(
                  label: 'Last 6 months',
                  isSelected:
                      _selectedDuration == DateRangeDuration.last6Months,
                  onTap: () =>
                      _setDateRangeForDuration(DateRangeDuration.last6Months),
                  primaryColor: _primaryColor,
                  unselectedTextColor: _unselectedTextColor,
                  labelTextStyle: _labelTextStyle,
                ),
                _DurationChip(
                  label: 'Custom',
                  isSelected: _selectedDuration == DateRangeDuration.custom,
                  onTap: () =>
                      _setDateRangeForDuration(DateRangeDuration.custom),
                  primaryColor: _primaryColor,
                  unselectedTextColor: _unselectedTextColor,
                  labelTextStyle: _labelTextStyle,
                ),
              ],
            ),
          ),
          const Gap(12),

          // Error message (if any)
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: _errorTextStyle,
                    ),
                  ),
                ],
              ),
            ),

          // Info text (only show if there's a limit)
          if (_hasRangeLimit && _maxRangeText != null)
            Text(
              'Custom range cannot exceed $_maxRangeText',
              style: _labelTextStyle,
            ),
          const Gap(16),

          // Start date field
          Text(
            'Start date',
            style: _labelTextStyle,
          ),
          const Gap(8),
          _DateField(
            value:
                _startDate != null ? _formatDate(_startDate!) : 'Select date',
            onTap: () => _pickDate(isStartDate: true),
            borderColor: _borderColor,
            dateTextStyle: _dateTextStyle,
          ),
          const Gap(16),

          // End date field
          Text(
            'End date',
            style: _labelTextStyle,
          ),
          const Gap(8),
          _DateField(
            value: _endDate != null ? _formatDate(_endDate!) : 'Select date',
            onTap: () => _pickDate(isStartDate: false),
            borderColor: _borderColor,
            dateTextStyle: _dateTextStyle,
          ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color unselectedTextColor;
  final TextStyle labelTextStyle;

  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.unselectedTextColor,
    required this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.2)
              : const Color(0xFF666666).withValues(alpha: 0.2),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : const Color(0xFF666666).withValues(alpha: 0.05),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: labelTextStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final Color borderColor;
  final TextStyle dateTextStyle;

  const _DateField({
    required this.value,
    required this.onTap,
    required this.borderColor,
    required this.dateTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: dateTextStyle,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
      ),
    );
  }
}
