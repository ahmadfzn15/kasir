import 'package:intl/intl.dart';

String formatNumber(int value) {
  NumberFormat numberFormat = NumberFormat("#,###");
  String formatNumber = numberFormat.format(value);

  return formatNumber;
}
