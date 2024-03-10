String formatNumber(int value) {
  String numStr = value.toString();
  String formatNumber = '';
  int length = numStr.length;

  for (int i = 0; i < length; i++) {
    if ((length - 1) % 3 == 0 && i != 0) {
      formatNumber += '.';
    }
    formatNumber += numStr[i];
  }

  return formatNumber;
}
