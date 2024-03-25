String formatTime(timestamp) {
  DateTime date = DateTime.parse(timestamp);
  date = date.toLocal();

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  int day = date.day;
  String time = '${date.hour}:${date.minute}:${date.second}';
  String month = months[date.month - 1];
  int year = date.year;

  String formattedDate = '$time, $day $month $year';

  return formattedDate;
}
