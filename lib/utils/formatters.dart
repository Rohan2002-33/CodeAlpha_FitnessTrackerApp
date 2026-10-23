import 'package:intl/intl.dart';

import 'date_utils.dart';

const List<String> weekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String formatNumber(int value) => NumberFormat.decimalPattern().format(value);

String friendlyDate(DateTime d) {
  final now = DateTime.now();
  if (isSameDay(d, now)) return 'Today';
  if (isSameDay(d, DateTime(now.year, now.month, now.day - 1))) {
    return 'Yesterday';
  }
  return DateFormat(d.year == now.year ? 'EEE, d MMM' : 'd MMM y').format(d);
}

String greeting(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
