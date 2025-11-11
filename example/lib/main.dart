import 'package:flutter/material.dart';
import 'package:month_range_picker_modal/month_range_picker_modal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Date Picker Modal Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  String _lastAction = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Custom Date Picker Modal Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Select a date or date range:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showMonthlyPicker(),
              child: const Text('Show Monthly Picker'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showCustomRangePicker(),
              child: const Text('Show Custom Range Picker'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showFullPicker(),
              child: const Text('Show Full Picker (with Tabs)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showCustomButtonPicker(),
              child: const Text('Show Picker with Custom Button'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showMonthRangeLimitPicker(),
              child:
                  const Text('Show Picker with Month Range Limit (6 months)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showYearRangeLimitPicker(),
              child: const Text('Show Picker with Year Range Limit (2 years)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showOnlyCustomRangePicker(),
              child: const Text('Show Only Custom Range Picker'),
            ),
            const SizedBox(height: 40),
            if (_selectedDate != null)
              Text(
                'Selected Date: ${_formatDate(_selectedDate!)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            if (_selectedDateRange != null)
              Column(
                children: [
                  Text(
                    'Start: ${_formatDate(_selectedDateRange!.start)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'End: ${_formatDate(_selectedDateRange!.end)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Text(
              'Last Action: $_lastAction',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMonthlyPicker() async {
    final result = await MonthRangePickerModal.show(
      context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      showTabs: false,
      headerText: 'Select Month and Year',
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;
      setState(() {
        switch (actionType) {
          case ActionType.confirm:
            if (selectedDate != null) {
              _selectedDate = selectedDate;
              _selectedDateRange = null;
              _lastAction = 'Monthly Selection Confirmed';
            }
            break;
          case ActionType.dateTimeRange:
            // Not applicable for monthly picker
            break;
          case ActionType.cancel:
            _lastAction = 'Cancelled';
            break;
          case ActionType.reset:
            _selectedDate = null;
            _selectedDateRange = null;
            _lastAction = 'Reset';
            break;
        }
      });
    }
  }

  Future<void> _showCustomRangePicker() async {
    final result = await MonthRangePickerModal.show(
      context,
      selectedTab: 1,
      initialDateTimeRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;
      setState(() {
        switch (actionType) {
          case ActionType.confirm:
            // Not applicable for custom range picker
            break;
          case ActionType.dateTimeRange:
            if (dateTimeRange != null) {
              _selectedDateRange = dateTimeRange;
              _selectedDate = null;
              _lastAction = 'Date Range Confirmed';
            }
            break;
          case ActionType.cancel:
            _lastAction = 'Cancelled';
            break;
          case ActionType.reset:
            _selectedDate = null;
            _selectedDateRange = null;
            _lastAction = 'Reset';
            break;
        }
      });
    }
  }

  Future<void> _showFullPicker() async {
    final result = await MonthRangePickerModal.show(
      context,
      initialDate: _selectedDate,
      initialDateTimeRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      showTabs: true,
      onValidationError: (context, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;
      setState(() {
        switch (actionType) {
          case ActionType.confirm:
            if (selectedDate != null) {
              _selectedDate = selectedDate;
              _selectedDateRange = null;
              _lastAction = 'Monthly Selection Confirmed';
            }
            break;
          case ActionType.dateTimeRange:
            if (dateTimeRange != null) {
              _selectedDateRange = dateTimeRange;
              _selectedDate = null;
              _lastAction = 'Date Range Confirmed';
            }
            break;
          case ActionType.cancel:
            _lastAction = 'Cancelled';
            break;
          case ActionType.reset:
            _selectedDate = null;
            _selectedDateRange = null;
            _lastAction = 'Reset';
            break;
        }
      });
    }
  }

  Future<void> _showCustomButtonPicker() async {
    final result = await MonthRangePickerModal.show(
      context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      showTabs: false,
      headerText: 'Select Month and Year',
      // Custom confirm button builder
      confirmButtonBuilder: (onConfirm) {
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onConfirm,
              borderRadius: BorderRadius.circular(8),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Apply Selection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;
      setState(() {
        switch (actionType) {
          case ActionType.confirm:
            if (selectedDate != null) {
              _selectedDate = selectedDate;
              _selectedDateRange = null;
              _lastAction = 'Custom Button - Date Confirmed';
            }
            break;
          case ActionType.dateTimeRange:
            // Not applicable for monthly picker
            break;
          case ActionType.cancel:
            _lastAction = 'Cancelled';
            break;
          case ActionType.reset:
            _selectedDate = null;
            _selectedDateRange = null;
            _lastAction = 'Reset';
            break;
        }
      });
    }
  }

  Future<void> _showMonthRangeLimitPicker() async {
    final result = await MonthRangePickerModal.show(
      context,
      selectedTab: 1,
      initialDateTimeRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      maxRangeMonths: 6, // Limit range to 6 months
      onValidationError: (context, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;
      setState(() {
        switch (actionType) {
          case ActionType.confirm:
            // Not applicable for custom range picker
            break;
          case ActionType.dateTimeRange:
            if (dateTimeRange != null) {
              _selectedDateRange = dateTimeRange;
              _selectedDate = null;
              _lastAction = 'Date Range Confirmed (6 months limit)';
            }
            break;
          case ActionType.cancel:
            _lastAction = 'Cancelled';
            break;
          case ActionType.reset:
            _selectedDate = null;
            _selectedDateRange = null;
            _lastAction = 'Reset';
            break;
        }
      });
    }
  }

  Future<void> _showYearRangeLimitPicker() async {
    final result = await MonthRangePickerModal.show(
      context,
      selectedTab: 1,
      initialDateTimeRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      maxRangeYears: 2, // Limit range to 1 year (12 months)
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;
      setState(() {
        switch (actionType) {
          case ActionType.confirm:
            // Not applicable for custom range picker
            break;
          case ActionType.dateTimeRange:
            if (dateTimeRange != null) {
              _selectedDateRange = dateTimeRange;
              _selectedDate = null;
              _lastAction = 'Date Range Confirmed (1 year limit)';
            }
            break;
          case ActionType.cancel:
            _lastAction = 'Cancelled';
            break;
          case ActionType.reset:
            _selectedDate = null;
            _selectedDateRange = null;
            _lastAction = 'Reset';
            break;
        }
      });
    }
  }

  Future<void> _showOnlyCustomRangePicker() async {
    final result = await MonthRangePickerModal.show(
      context,
      showOnlyCustomRange: true, // Show only Custom range picker (no tabs)
      initialDateTimeRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      headerText: 'Select Date Range',
      onValidationError: (context, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );

    if (result != null) {
      final (selectedDate, dateTimeRange, actionType) = result;
      setState(() {
        switch (actionType) {
          case ActionType.confirm:
            // Not applicable for custom range picker
            break;
          case ActionType.dateTimeRange:
            if (dateTimeRange != null) {
              _selectedDateRange = dateTimeRange;
              _selectedDate = null;
              _lastAction = 'Custom Range Only - Date Range Confirmed';
            }
            break;
          case ActionType.cancel:
            _lastAction = 'Cancelled';
            break;
          case ActionType.reset:
            _selectedDate = null;
            _selectedDateRange = null;
            _lastAction = 'Reset';
            break;
        }
      });
    }
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
}
