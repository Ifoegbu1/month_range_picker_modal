import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'widgets/custom_date_range.dart';
import 'widgets/month_year_picker.dart';

/// Action types that can be returned from the date picker modal.
enum ActionType { confirm, cancel, reset, dateTimeRange }

/// A custom date picker modal that allows users to select a month/year or a date range.
///
/// This widget provides two modes:
/// - **Monthly**: Select a specific month and year
/// - **Custom**: Select a custom date range with preset options (Last 3 months, Last 6 months, or custom range)
///
/// Example usage:
/// ```dart
/// final result = await CustomDatePickerModal.show(
///   context,
///   initialDate: DateTime.now(),
///   firstDate: DateTime(2020),
///   lastDate: DateTime.now(),
/// );
///
/// if (result != null) {
///   final (selectedDate, dateTimeRange, actionType) = result;
///   if (actionType == ActionType.confirm) {
///     // Handle date selection
///   }
/// }
/// ```
class MonthRangePicker extends StatefulWidget {
  /// The selected tab index.
  /// 0 for Monthly, 1 for Custom.
  /// Defaults to 0.
  final int selectedTab;

  /// The initial date to be selected when the picker opens.
  /// If both [initialDate] and [initialDateTimeRange] are provided, an assertion error will be thrown.
  final DateTime? initialDate;

  /// The earliest date that can be selected. Used to limit the available years in the picker.
  final DateTime? firstDate;

  /// The latest date that can be selected. Used to limit the available years and months in the picker.
  /// If [showAllMonths] is false, months beyond this date will be filtered out.
  final DateTime? lastDate;

  /// Callback function that is called when a date is confirmed.
  final Function(DateTime)? onConfirm;

  /// Whether to show tabs for switching between "Monthly" and "Custom" date range selection modes.
  /// Defaults to `true`.
  final bool showTabs;

  /// Whether to show only the Custom range picker (without tabs or Monthly picker).
  /// When `true`, only the Custom date range picker is displayed.
  /// Defaults to `false`.
  final bool showOnlyCustomRange;

  /// The header text displayed at the top of the picker modal.
  /// Defaults to 'Select month and year'.
  final String headerText;

  /// The initial date range to be selected when the picker opens.
  /// If both [initialDate] and [initialDateTimeRange] are provided, an assertion error will be thrown.
  final DateTimeRange? initialDateTimeRange;

  /// Whether to show all 12 months regardless of [lastDate] restriction.
  /// When `true`, all months are displayed even if they exceed [lastDate].
  /// When `false`, months are filtered based on [lastDate] (e.g., if current month is November,
  /// only months up to November will be shown).
  /// Defaults to `false`.
  final bool showAllMonths;

  /// Primary color for the picker. If null, uses Theme.of(context).colorScheme.primary.
  final Color? primaryColor;

  /// Color for unselected text. If null, uses Theme.of(context).textTheme.bodyMedium?.color with opacity.
  final Color? unselectedTextColor;

  /// Global font family that applies across all text in the picker.
  /// This font family will be merged into all TextStyles (both custom and default).
  /// If null, uses Theme.of(context).textTheme.bodyMedium?.fontFamily.
  final String? fontFamily;

  /// Text style for tab labels. If null, uses Theme.of(context).textTheme.titleMedium with default font weight.
  final TextStyle? tabTextStyle;

  /// Text style for header text. If null, uses Theme.of(context).textTheme.titleMedium.
  final TextStyle? headerTextStyle;

  /// Text style for month/year picker text. If null, uses Theme.of(context).textTheme.headlineSmall.
  final TextStyle? pickerTextStyle;

  /// Text style for date field labels and values. If null, uses Theme.of(context).textTheme.bodyLarge.
  final TextStyle? dateTextStyle;

  /// Text style for button text. If null, uses Theme.of(context).textTheme.labelLarge with white color.
  final TextStyle? buttonTextStyle;

  /// Text style for error messages. If null, uses Theme.of(context).textTheme.bodyMedium with red color.
  final TextStyle? errorTextStyle;

  /// Text style for info/label text. If null, uses Theme.of(context).textTheme.bodyMedium.
  final TextStyle? labelTextStyle;

  /// Maximum allowed range in months for custom date range selection.
  /// If null and [maxRangeYears] is also null, no limit is applied (unlimited range).
  /// If [maxRangeYears] is provided, this parameter is ignored.
  final int? maxRangeMonths;

  /// Maximum allowed range in years for custom date range selection. If provided, takes precedence over [maxRangeMonths].
  /// For example, 1 year = 12 months, 2 years = 24 months.
  /// If both [maxRangeYears] and [maxRangeMonths] are null, no limit is applied (unlimited range).
  final int? maxRangeYears;

  /// Builder for custom confirm button. If provided, this will be used instead of the default button.
  /// The builder receives a [VoidCallback] that should be called when the button is pressed.
  /// If null, uses the default ElevatedButton.
  final Widget Function(VoidCallback onConfirm)? confirmButtonBuilder;

  /// Callback for showing validation errors. If null, uses a default inline error display.
  final void Function(BuildContext context, String message)? onValidationError;

  const MonthRangePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.selectedTab = 0,
    this.onConfirm,
    this.initialDateTimeRange,
    this.showTabs = true,
    this.showOnlyCustomRange = false,
    this.headerText = 'Select month and year',
    this.showAllMonths = false,
    this.primaryColor,
    this.unselectedTextColor,
    this.fontFamily,
    this.tabTextStyle,
    this.headerTextStyle,
    this.pickerTextStyle,
    this.dateTextStyle,
    this.buttonTextStyle,
    this.errorTextStyle,
    this.labelTextStyle,
    this.maxRangeMonths,
    this.maxRangeYears,
    this.confirmButtonBuilder,
    this.onValidationError,
  }) : assert(
          !(initialDate != null && initialDateTimeRange != null),
          'Both initialDate and initialDateTimeRange cannot be provided',
        );

  @override
  State<MonthRangePicker> createState() => _MonthRangePickerState();

  /// Shows the date picker modal as a bottom sheet.
  ///
  /// Returns a tuple containing:
  /// - `DateTime?`: The selected date (when monthly selection is used)
  /// - `DateTimeRange?`: The selected date range (when custom range is used)
  /// - `ActionType`: The action that was taken (confirm, cancel, reset, or dateTimeRange)
  ///
  /// Returns `null` if the modal was dismissed without selection.
  ///
  /// Parameters:
  /// - [context]: The build context used to show the modal bottom sheet.
  /// - [initialDate]: The initial date to be selected when the picker opens.
  /// - [firstDate]: The earliest date that can be selected. Defaults to `DateTime(2020)` if not provided.
  /// - [lastDate]: The latest date that can be selected. Defaults to `DateTime.now()` if not provided.
  /// - [selectedTab]: The selected tab index. Defaults to 0.
  /// - [showTabs]: Whether to show tabs for switching between "Monthly" and "Custom" selection modes.
  ///   Defaults to `true`.
  /// - [showOnlyCustomRange]: Whether to show only the Custom range picker (without tabs or Monthly picker).
  ///   When `true`, only the Custom date range picker is displayed.
  ///   Defaults to `false`.
  /// - [initialDateTimeRange]: The initial date range to be selected when the picker opens.
  /// - [headerText]: The header text displayed at the top of the picker modal.
  ///   Defaults to 'Select month and year'.
  /// - [showAllMonths]: Whether to show all 12 months regardless of [lastDate] restriction.
  ///   When `true`, all months are displayed even if they exceed [lastDate].
  ///   When `false`, months are filtered based on [lastDate].
  ///   Defaults to `false`.
  /// - [primaryColor]: Primary color for the picker. If null, uses Theme.of(context).colorScheme.primary.
  /// - [unselectedTextColor]: Color for unselected text. If null, uses Theme.of(context).textTheme.bodyMedium?.color with opacity.
  /// - [fontFamily]: Global font family that applies across all text in the picker. This font family will be merged into all TextStyles.
  /// - [tabTextStyle]: Text style for tab labels. If null, uses Theme defaults.
  /// - [headerTextStyle]: Text style for header text. If null, uses Theme defaults.
  /// - [pickerTextStyle]: Text style for month/year picker text. If null, uses Theme defaults.
  /// - [dateTextStyle]: Text style for date field labels and values. If null, uses Theme defaults.
  /// - [buttonTextStyle]: Text style for button text. If null, uses Theme defaults.
  /// - [errorTextStyle]: Text style for error messages. If null, uses Theme defaults with red color.
  /// - [labelTextStyle]: Text style for info/label text. If null, uses Theme defaults.
  /// - [maxRangeMonths]: Maximum allowed range in months for custom date range selection.
  ///   If null and [maxRangeYears] is also null, no limit is applied (unlimited range).
  ///   If [maxRangeYears] is provided, this parameter is ignored.
  /// - [maxRangeYears]: Maximum allowed range in years for custom date range selection. If provided, takes precedence over [maxRangeMonths].
  ///   If both [maxRangeYears] and [maxRangeMonths] are null, no limit is applied (unlimited range).
  /// - [confirmButtonBuilder]: Builder for custom confirm button. If provided, this will be used instead of the default button.
  ///   The builder receives a [VoidCallback] that should be called when the button is pressed.
  /// - [onValidationError]: Callback for showing validation errors. If null, uses a default inline error display.
  static Future<(DateTime?, DateTimeRange?, ActionType)?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    int selectedTab = 0,
    bool showTabs = true,
    bool showOnlyCustomRange = false,
    DateTimeRange? initialDateTimeRange,
    String headerText = 'Select month and year',
    bool showAllMonths = false,
    Color? primaryColor,
    Color? unselectedTextColor,
    String? fontFamily,
    TextStyle? tabTextStyle,
    TextStyle? headerTextStyle,
    TextStyle? pickerTextStyle,
    TextStyle? dateTextStyle,
    TextStyle? buttonTextStyle,
    TextStyle? errorTextStyle,
    TextStyle? labelTextStyle,
    int? maxRangeMonths,
    int? maxRangeYears,
    Widget Function(VoidCallback onConfirm)? confirmButtonBuilder,
    void Function(BuildContext context, String message)? onValidationError,
  }) async {
    return await showModalBottomSheet<(DateTime?, DateTimeRange?, ActionType)?>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      showDragHandle: true,
      builder: (context) => MonthRangePicker(
        selectedTab: selectedTab,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDateTimeRange: initialDateTimeRange,
        showTabs: showTabs,
        showOnlyCustomRange: showOnlyCustomRange,
        headerText: headerText,
        showAllMonths: showAllMonths,
        primaryColor: primaryColor,
        unselectedTextColor: unselectedTextColor,
        fontFamily: fontFamily,
        tabTextStyle: tabTextStyle,
        headerTextStyle: headerTextStyle,
        pickerTextStyle: pickerTextStyle,
        dateTextStyle: dateTextStyle,
        buttonTextStyle: buttonTextStyle,
        errorTextStyle: errorTextStyle,
        labelTextStyle: labelTextStyle,
        maxRangeMonths: maxRangeMonths,
        maxRangeYears: maxRangeYears,
        confirmButtonBuilder: confirmButtonBuilder,
        onValidationError: onValidationError,
      ),
    );
  }
}

class _MonthRangePickerState extends State<MonthRangePicker>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  late int _selectedMonthIndex;
  late int _selectedYearIndex;
  late TabController _tabController;
  DateTime? selectedDate;
  DateTimeRange? dateTimeRange;
  final GlobalKey<CustomDateRangeState> _customDateRangeKey =
      GlobalKey<CustomDateRangeState>();
  final List<String> _months = [
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

  late List<int> _years;
  late List<String> _availableMonths;

  Color get _primaryColor =>
      widget.primaryColor ?? Theme.of(context).colorScheme.primary;

  Color get _unselectedTextColor =>
      widget.unselectedTextColor ??
      (Theme.of(context).textTheme.bodyMedium?.color ??
          Colors.grey.withValues(alpha: 0.6));

  String? get _fontFamily =>
      widget.fontFamily ?? Theme.of(context).textTheme.bodyMedium?.fontFamily;

  /// Merges fontFamily into a TextStyle if fontFamily is provided
  TextStyle _mergeFontFamily(TextStyle style) {
    if (_fontFamily != null) {
      return style.copyWith(fontFamily: _fontFamily);
    }
    return style;
  }

  TextStyle get _tabTextStyle {
    final baseStyle = widget.tabTextStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    return _mergeFontFamily(baseStyle);
  }

  TextStyle get _headerTextStyle {
    final baseStyle = widget.headerTextStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    return _mergeFontFamily(baseStyle);
  }

  TextStyle get _pickerTextStyle {
    final baseStyle = widget.pickerTextStyle ??
        Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    return _mergeFontFamily(baseStyle);
  }

  TextStyle get _dateTextStyle {
    final baseStyle = widget.dateTextStyle ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16) ??
        const TextStyle(fontSize: 16);
    return _mergeFontFamily(baseStyle);
  }

  TextStyle get _buttonTextStyle {
    final baseStyle = widget.buttonTextStyle ??
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 16,
            ) ??
        const TextStyle(color: Colors.white, fontSize: 16);
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

  TextStyle get _labelTextStyle {
    final baseStyle = widget.labelTextStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16) ??
        const TextStyle(fontSize: 16);
    return _mergeFontFamily(baseStyle);
  }

  List<String> _getAvailableMonths(int year) {
    // If showAllMonths is true, always return all months
    if (widget.showAllMonths) {
      return _months;
    }

    final lastDate = widget.lastDate;
    if (lastDate == null) {
      return _months;
    }

    // If the selected year is the same as lastDate's year, filter months
    if (year == lastDate.year) {
      final maxMonth = lastDate.month;
      return _months.sublist(0, maxMonth);
    }

    // For past years, show all months
    return _months;
  }

  @override
  void initState() {
    // If showOnlyCustomRange is true, force tab to 1 (Custom tab)
    _selectedTab = widget.showOnlyCustomRange ? 1 : widget.selectedTab;
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedTab,
    );

    _tabController.addListener(onTabChanged);

    final now = widget.initialDate ?? DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    final firstDate = widget.firstDate ?? DateTime(now.year);
    final lastDate = widget.lastDate ?? DateTime(now.year);

    _years = List.generate(
      lastDate.year - firstDate.year + 1,
      (index) => firstDate.year + index,
    );

    _selectedMonthIndex = now.month - 1;
    _selectedYearIndex = _years.indexOf(now.year);

    // Initialize available months based on selected year
    _availableMonths = _getAvailableMonths(_years[_selectedYearIndex]);

    // Adjust month index if it's beyond available months
    if (_selectedMonthIndex >= _availableMonths.length) {
      _selectedMonthIndex = _availableMonths.length - 1;
    }

    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonthIndex,
    );
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYearIndex,
    );
  }

  void onTabChanged() {
    setState(() {
      _selectedTab = _tabController.index;
    });
  }

  void _reset() {
    // Reset selected date and date range
    selectedDate = null;
    dateTimeRange = null;

    // Reset monthly picker to initial values
    final now = widget.initialDate ?? DateTime.now();
    final initialMonthIndex = now.month - 1;
    final initialYearIndex = _years.indexOf(now.year);

    // Ensure year index is valid
    final validYearIndex = initialYearIndex >= 0
        ? initialYearIndex
        : _years.isNotEmpty
            ? _years.length - 1
            : 0;

    setState(() {
      _selectedMonthIndex = initialMonthIndex;
      _selectedYearIndex = validYearIndex;

      // Update available months based on selected year
      _availableMonths = _getAvailableMonths(_years[_selectedYearIndex]);

      // Adjust month index if it's beyond available months
      if (_selectedMonthIndex >= _availableMonths.length) {
        _selectedMonthIndex = _availableMonths.length - 1;
      }
    });

    // Reset controllers after setState to ensure UI updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monthController.jumpToItem(_selectedMonthIndex);
      _yearController.jumpToItem(_selectedYearIndex);
    });

    // Reset custom date range if it exists
    final customDateRangeState = _customDateRangeKey.currentState;
    if (customDateRangeState != null) {
      customDateRangeState.reset();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _tabController.removeListener(onTabChanged);
    super.dispose();
  }

  void _onConfirm() {
    // If Custom tab is selected or showOnlyCustomRange is true, validate the date range
    if (_selectedTab == 1 || widget.showOnlyCustomRange) {
      final customDateRangeState = _customDateRangeKey.currentState;
      if (customDateRangeState != null) {
        // Validate and only proceed if validation passes
        if (!customDateRangeState.validateAndNotify(
          onValidationError: widget.onValidationError,
        )) {
          return; // Don't close the modal if validation fails
        }

        dateTimeRange = DateTimeRange(
          start: customDateRangeState.startDate!,
          end: customDateRangeState.endDate!,
        );

        Navigator.of(context)
            .pop((selectedDate, dateTimeRange, ActionType.dateTimeRange));
      }
    } else {
      // Monthly tab - use the selected month/year
      // Get the actual month index from available months
      final monthName = _availableMonths[_selectedMonthIndex];
      final actualMonthIndex = _months.indexOf(monthName);
      selectedDate = DateTime(_years[_selectedYearIndex], actualMonthIndex + 1);
      Navigator.of(context)
          .pop((selectedDate, dateTimeRange, ActionType.confirm));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context)
              .pop((selectedDate, dateTimeRange, ActionType.cancel));
        }
      },
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height *
              (widget.showOnlyCustomRange || _selectedTab == 1 ? 0.52 : 0.45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.showOnlyCustomRange
                  ? Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const BackButton(),
                              Text(
                                widget.headerText,
                                style: _headerTextStyle,
                              ),
                            ],
                          ),
                          Tooltip(
                            message: 'Reset',
                            child: IconButton(
                              onPressed: () {
                                _reset();
                                Navigator.of(context).pop(
                                  (
                                    selectedDate,
                                    dateTimeRange,
                                    ActionType.reset,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.restart_alt, size: 24),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : widget.showTabs
                      ? Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                indicatorSize: TabBarIndicatorSize.tab,
                                splashBorderRadius: BorderRadius.circular(8),
                                indicator: UnderlineTabIndicator(
                                  borderSide: BorderSide(
                                    color: _primaryColor,
                                    width: 2,
                                  ),
                                  insets:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                unselectedLabelColor: _unselectedTextColor,
                                labelStyle: _tabTextStyle,
                                unselectedLabelStyle: _tabTextStyle.copyWith(
                                  color: _unselectedTextColor,
                                ),
                                dividerColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                tabs: const [
                                  Tab(text: 'Monthly'),
                                  Tab(text: 'Custom'),
                                ],
                              ),
                              Tooltip(
                                message: 'Reset',
                                child: IconButton(
                                  onPressed: () {
                                    _reset();
                                    Navigator.of(context).pop(
                                      (
                                        selectedDate,
                                        dateTimeRange,
                                        ActionType.reset,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.restart_alt, size: 24),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const BackButton(),
                                  Text(
                                    widget.headerText,
                                    style: _headerTextStyle,
                                  ),
                                ],
                              ),
                              Tooltip(
                                message: 'Reset',
                                child: IconButton(
                                  onPressed: () {
                                    _reset();
                                    Navigator.of(context).pop(
                                      (
                                        selectedDate,
                                        dateTimeRange,
                                        ActionType.reset,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.restart_alt, size: 24),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                        ),
              widget.showOnlyCustomRange
                  ? Expanded(
                      child: CustomDateRange(
                        key: _customDateRangeKey,
                        showAllMonths: widget.showAllMonths,
                        initialDateTimeRange: widget.initialDateTimeRange,
                        primaryColor: _primaryColor,
                        unselectedTextColor: _unselectedTextColor,
                        dateTextStyle: _dateTextStyle,
                        labelTextStyle: _labelTextStyle,
                        errorTextStyle: _errorTextStyle,
                        fontFamily: _fontFamily,
                        maxRangeMonths: widget.maxRangeMonths,
                        maxRangeYears: widget.maxRangeYears,
                        onValidationError: widget.onValidationError,
                      ),
                    )
                  : widget.showTabs
                      ? Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              MonthYearPicker(
                                months: _availableMonths,
                                years: _years,
                                monthController: _monthController,
                                yearController: _yearController,
                                selectedMonthIndex: _selectedMonthIndex,
                                selectedYearIndex: _selectedYearIndex,
                                primaryColor: _primaryColor,
                                unselectedTextColor: _unselectedTextColor,
                                pickerTextStyle: _pickerTextStyle,
                                fontFamily: _fontFamily,
                                onMonthChanged: (index) {
                                  setState(() {
                                    _selectedMonthIndex = index;
                                  });
                                },
                                onYearChanged: (index) {
                                  setState(() {
                                    _selectedYearIndex = index;
                                    // Update available months based on new year
                                    final oldLength = _availableMonths.length;
                                    _availableMonths = _getAvailableMonths(
                                      _years[index],
                                    );
                                    // Adjust month index if needed
                                    if (_selectedMonthIndex >=
                                        _availableMonths.length) {
                                      _selectedMonthIndex =
                                          _availableMonths.length - 1;
                                    }
                                    // Reset month controller if month list changed
                                    if (oldLength != _availableMonths.length) {
                                      _monthController.jumpToItem(
                                        _selectedMonthIndex,
                                      );
                                    }
                                  });
                                },
                              ),
                              CustomDateRange(
                                key: _customDateRangeKey,
                                showAllMonths: widget.showAllMonths,
                                initialDateTimeRange:
                                    widget.initialDateTimeRange,
                                primaryColor: _primaryColor,
                                unselectedTextColor: _unselectedTextColor,
                                dateTextStyle: _dateTextStyle,
                                labelTextStyle: _labelTextStyle,
                                errorTextStyle: _errorTextStyle,
                                fontFamily: _fontFamily,
                                maxRangeMonths: widget.maxRangeMonths,
                                maxRangeYears: widget.maxRangeYears,
                                onValidationError: widget.onValidationError,
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: MonthYearPicker(
                            months: _availableMonths,
                            years: _years,
                            monthController: _monthController,
                            yearController: _yearController,
                            selectedMonthIndex: _selectedMonthIndex,
                            selectedYearIndex: _selectedYearIndex,
                            primaryColor: _primaryColor,
                            unselectedTextColor: _unselectedTextColor,
                            pickerTextStyle: _pickerTextStyle,
                            fontFamily: _fontFamily,
                            onMonthChanged: (index) {
                              setState(() {
                                _selectedMonthIndex = index;
                              });
                            },
                            onYearChanged: (index) {
                              setState(() {
                                _selectedYearIndex = index;
                                // Update available months based on new year
                                final oldLength = _availableMonths.length;
                                _availableMonths =
                                    _getAvailableMonths(_years[index]);
                                // Adjust month index if needed
                                if (_selectedMonthIndex >=
                                    _availableMonths.length) {
                                  _selectedMonthIndex =
                                      _availableMonths.length - 1;
                                }
                                // Reset month controller if month list changed
                                if (oldLength != _availableMonths.length) {
                                  _monthController
                                      .jumpToItem(_selectedMonthIndex);
                                }
                              });
                            },
                          ),
                        ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: widget.confirmButtonBuilder != null
                    ? widget.confirmButtonBuilder!(_onConfirm)
                    : ElevatedButton(
                        onPressed: _onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: _buttonTextStyle,
                        ),
                      ),
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alias for [MonthRangePicker] for better API naming consistency.
typedef MonthRangePickerModal = MonthRangePicker;
