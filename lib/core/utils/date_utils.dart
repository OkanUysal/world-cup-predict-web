import 'package:intl/intl.dart';

class AppDateUtils {
  static final _format = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');

  static String formatUtc(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return _format.format(date);
    } catch (_) {
      return isoString;
    }
  }
}
