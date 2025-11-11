# month_range_picker_modal

A customizable Flutter date picker modal that supports month/year selection and custom date range selection with preset options.

## Features

- 📅 **Monthly Selection**: Select a specific month and year using wheel pickers
- 📆 **Custom Date Range**: Select custom date ranges with preset options (Last 3 months, Last 6 months, or custom range)
- 🔄 **Reset Functionality**: Reset button to clear all selections and return to initial state
- 🎨 **Customizable**: Supports custom colors, fonts, and validation error handling
- 📱 **Responsive**: Adapts to different screen sizes
- ♿ **Accessible**: Built with accessibility in mind
- 🎯 **Flexible Display Modes**: Show tabs, monthly picker only, or custom range picker only

## Screenshots

| Image                                                                                                                                                       | Description                         |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| <img width="260" alt="month_range_picker" src="https://github.com/user-attachments/assets/6f784422-0b6a-485d-bc92-d1fa5a0ad148" />            | Monthly picker default view         |
| <img width="260"  alt="month_range_picker1" src="https://github.com/user-attachments/assets/1f50cd39-19ab-4465-ad07-9b49b6cdb09f" />           | Alternate monthly picker state      |
| <img width="260"  alt="month_range_picker_with_limit" src="https://github.com/user-attachments/assets/54c997dd-a4eb-4903-9c8f-fac78ce3000c" /> | Picker with max range limit applied |
| <img width="260"  alt="month_range_picker_limit_error" src="https://github.com/user-attachments/assets/b04d8870-e002-43d8-a7f0-b2fc7dc08266" /> |Validation error when limit exceeded |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  month_range_picker_modal: ^1.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Monthly Selection

```dart
import 'package:month_range_picker_modal/month_range_picker_modal.dart';

// Show the date picker modal
final result = await MonthRangePickerModal.show(
  context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime.now(),
);

if (result != null) {
  final (selectedDate, dateTimeRange, actionType) = result;
  switch (actionType) {
    case ActionType.confirm:
      if (selectedDate != null) {
        print('Selected date: $selectedDate');
      }
      break;
    case ActionType.cancel:
      print('Cancelled');
      break;
    case ActionType.reset:
      print('Reset');
      break;
    case ActionType.dateTimeRange:
      // Not applicable for monthly picker
      break;
  }
}
```

### Custom Date Range Selection

```dart
final result = await MonthRangePickerModal.show(
  context,
  selectedTab: 1, // Switch to Custom tab
  initialDateTimeRange: DateTimeRange(
    start: DateTime(2024, 1, 1),
    end: DateTime(2024, 3, 31),
  ),
);

if (result != null) {
  final (selectedDate, dateTimeRange, actionType) = result;
  switch (actionType) {
    case ActionType.dateTimeRange:
      if (dateTimeRange != null) {
        print('Start: ${dateTimeRange.start}');
        print('End: ${dateTimeRange.end}');
      }
      break;
    case ActionType.cancel:
      print('Cancelled');
      break;
    case ActionType.reset:
      print('Reset');
      break;
    case ActionType.confirm:
      // Not applicable for custom range picker
      break;
  }
}
```

### Customization

```dart
final result = await MonthRangePickerModal.show(
  context,
  initialDate: DateTime.now(),
  primaryColor: Colors.blue,
  unselectedTextColor: Colors.grey,
  fontFamily: 'Roboto',
  headerText: 'Choose a date',
  // Set maximum range limit (in months or years)
  maxRangeYears: 2, // Allows up to 2 years
  // OR
  maxRangeMonths: 18, // Allows up to 18 months
  onValidationError: (context, message) {
    // Custom error handling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  },
);
```

### MonthRangePickerModal.show()

| Parameter              | Type                                  | Description                                                                      | Default                     |
| ---------------------- | ------------------------------------- | -------------------------------------------------------------------------------- | --------------------------- |
| `context`              | `BuildContext`                        | The build context                                                                | Required                    |
| `initialDate`          | `DateTime?`                           | Initial date to select                                                           | `null`                      |
| `firstDate`            | `DateTime?`                           | Earliest selectable date                                                         | `DateTime(2020)`            |
| `lastDate`             | `DateTime?`                           | Latest selectable date                                                           | `DateTime.now()`            |
| `selectedTab`          | `int`                                 | Initial tab (0 = Monthly, 1 = Custom)                                            | `0`                         |
| `showTabs`             | `bool`                                | Whether to show tabs                                                             | `true`                      |
| `showOnlyCustomRange`  | `bool`                                | Show only Custom range picker (no tabs or Monthly picker)                        | `false`                     |
| `initialDateTimeRange` | `DateTimeRange?`                      | Initial date range                                                               | `null`                      |
| `headerText`           | `String`                              | Header text when tabs are hidden                                                 | `'Select month and year'`   |
| `showAllMonths`        | `bool`                                | Show all months regardless of `lastDate`                                         | `false`                     |
| `primaryColor`         | `Color?`                              | Primary color for the picker                                                     | Theme primary color         |
| `unselectedTextColor`  | `Color?`                              | Color for unselected text                                                        | Theme body color with alpha |
| `fontFamily`           | `String?`                             | Global font family applied to all text                                           | Theme font family           |
| `tabTextStyle`         | `TextStyle?`                          | Text style for tab labels                                                        | Theme default               |
| `headerTextStyle`      | `TextStyle?`                          | Text style for header text                                                       | Theme default               |
| `pickerTextStyle`      | `TextStyle?`                          | Text style for month/year pickers                                                | Theme default               |
| `dateTextStyle`        | `TextStyle?`                          | Text style for date field labels and values                                      | Theme default               |
| `buttonTextStyle`      | `TextStyle?`                          | Text style for the confirm button text                                           | Theme default               |
| `errorTextStyle`       | `TextStyle?`                          | Text style for error messages                                                    | Theme default (red)         |
| `labelTextStyle`       | `TextStyle?`                          | Text style for info/label text                                                   | Theme default               |
| `maxRangeMonths`       | `int?`                                | Maximum allowed range in months (ignored if `maxRangeYears` provided)            | `null` (unlimited)          |
| `maxRangeYears`        | `int?`                                | Maximum allowed range in years (takes precedence over `maxRangeMonths`)          | `null` (unlimited)          |
| `confirmButtonBuilder` | `Widget Function(VoidCallback)?`      | Builder for a custom confirm button; receives a callback to trigger confirmation | Default ElevatedButton      |
| `onValidationError`    | `void Function(BuildContext,String)?` | Callback to display validation errors                                            | Inline error message        |

### Return Value

Returns a tuple `(DateTime?, DateTimeRange?, ActionType)?`:

- `DateTime?`: Selected date (for monthly selection)
- `DateTimeRange?`: Selected date range (for custom range)
- `ActionType`: The action taken (`confirm`, `cancel`, `reset`, or `dateTimeRange`)

Returns `null` if the modal was dismissed without selection.

### ActionType Enum

- `ActionType.confirm`: User confirmed monthly date selection
- `ActionType.dateTimeRange`: User confirmed custom date range selection
- `ActionType.cancel`: User cancelled/dismissed the modal
- `ActionType.reset`: User clicked the reset button (clears all selections)

## Customization Options

### Colors

You can customize the appearance by providing:

- `primaryColor`: Used for selected items, tabs, and buttons
- `unselectedTextColor`: Used for unselected month/year text

### Fonts

- `fontFamily`: Custom font family for all text

### Validation

- `onValidationError`: Custom callback for handling validation errors

## Limitations

- Custom date ranges are unlimited by default. You can set a limit using `maxRangeMonths` or `maxRangeYears` parameters.
- Date range validation ensures start date is before end date

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Charles Ifoegbu

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub Issues page](https://github.com/Ifoegbu1/month_range_picker_modal/issues).
