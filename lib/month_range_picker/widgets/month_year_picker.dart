import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// A widget that displays month and year pickers using wheel scroll views.
class MonthYearPicker extends StatefulWidget {
  /// List of month abbreviations (e.g., ['Jan', 'Feb', ...]).
  final List<String> months;

  /// List of available years.
  final List<int> years;

  /// Controller for the month picker scroll view.
  final FixedExtentScrollController monthController;

  /// Controller for the year picker scroll view.
  final FixedExtentScrollController yearController;

  /// Currently selected month index.
  final int selectedMonthIndex;

  /// Currently selected year index.
  final int selectedYearIndex;

  /// Callback when month selection changes.
  final ValueChanged<int> onMonthChanged;

  /// Callback when year selection changes.
  final ValueChanged<int> onYearChanged;

  /// Primary color for selected items. If null, uses Theme.of(context).colorScheme.primary.
  final Color? primaryColor;

  /// Color for unselected text. If null, uses Theme.of(context).textTheme.bodyMedium?.color with opacity.
  final Color? unselectedTextColor;

  /// Text style for picker text. If null, uses Theme.of(context).textTheme.headlineSmall.
  final TextStyle? pickerTextStyle;

  /// Global font family that applies across all text. This will be merged into pickerTextStyle if provided.
  final String? fontFamily;

  const MonthYearPicker({
    super.key,
    required this.months,
    required this.years,
    required this.monthController,
    required this.yearController,
    required this.selectedMonthIndex,
    required this.selectedYearIndex,
    required this.onMonthChanged,
    required this.onYearChanged,
    this.primaryColor,
    this.unselectedTextColor,
    this.pickerTextStyle,
    this.fontFamily,
  });

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Color get _unselectedTextColor =>
      widget.unselectedTextColor ??
      (Theme.of(context).textTheme.bodyMedium?.color ??
          Colors.grey.withValues(alpha: 0.6));

  TextStyle get _pickerTextStyle {
    final baseStyle = widget.pickerTextStyle ??
        Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    // Merge fontFamily if provided
    if (widget.fontFamily != null) {
      return baseStyle.copyWith(fontFamily: widget.fontFamily);
    }
    return baseStyle;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        // Month and Year pickers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Month picker
            SizedBox(
              width: 80,
              child: ListWheelScrollView.useDelegate(
                controller: widget.monthController,
                itemExtent: 37,
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.002,
                diameterRatio: 1.5,
                onSelectedItemChanged: widget.onMonthChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final isSelected = index == widget.selectedMonthIndex;
                    return Center(
                      child: Text(
                        widget.months[index],
                        style: _pickerTextStyle.copyWith(
                          color: isSelected ? null : _unselectedTextColor,
                        ),
                      ),
                    );
                  },
                  childCount: widget.months.length,
                ),
              ),
            ),

            const Gap(45),

            // Year picker
            SizedBox(
              width: 80,
              child: ListWheelScrollView.useDelegate(
                controller: widget.yearController,
                itemExtent: 37,
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.002,
                diameterRatio: 1.5,
                onSelectedItemChanged: widget.onYearChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final isSelected = index == widget.selectedYearIndex;
                    return Center(
                      child: Text(
                        widget.years[index].toString(),
                        style: _pickerTextStyle.copyWith(
                          color: isSelected ? null : _unselectedTextColor,
                        ),
                      ),
                    );
                  },
                  childCount: widget.years.length,
                ),
              ),
            ),
          ],
        ),
        // Selection indicator background
        IgnorePointer(
          child: Align(
            child: Container(
              height: 52,
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }
}
