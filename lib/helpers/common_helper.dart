import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

String durationToString(num minutes, {withoutMinute=false, withLabel=true}) {
  var d = Duration(minutes:minutes.toInt());
  List<String> parts = d.toString().split(':');
  if (withoutMinute) return "${parts[0]}${withLabel ? 'Jam' : ''}";

  if (int.parse(parts[0]) < 1) {
    return '${int.parse(parts[1])} ${withLabel ? 'Menit' : ''}';
  }
  if (int.parse(parts[1]) < 1) {
    return '${parts[0]} ${withLabel ? 'Jam' : ''}';
  }
  return '${parts[0]} ${withLabel ? 'Jam' : ''} ${int.parse(parts[1])} ${withLabel ? 'Menit' : ''}';
}

String convertMinuteToHoursMinute(num minutes) {
  var d = Duration(minutes:minutes.toInt());
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}

String convertToAgo(DateTime input){
  Duration diff = DateTime.now().difference(input);

  if (diff.inDays >= 1) {
    if (diff.inDays >= 365) {
      final years = diff.inDays ~/ 365;
      return '$years tahun yang lalu';
    } else if (diff.inDays >= 30) {
      final months = (diff.inDays % 365) ~/ 30;
      return '$months bulan yang lalu';
    }
    return '${diff.inDays} hari yang lalu';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours} jam yang lalu';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} menit yang lalu';
  } else if (diff.inSeconds >= 1) {
    return '${diff.inSeconds} detik yang lalu';
  } else {
    return 'sekarang';
  }
}

String rupiahNumberFormatter(String? val, [isWithoutComma=false]) {
  try {
    if (val == null) {
      return "0";
    } else if (val.trim().isEmpty) {
      return "0";
    }
    return NumberFormat.currency(symbol: 'Rp. ', decimalDigits: isWithoutComma ? 0 : 2,).format(num.parse(val)).toString();
  } catch (e) {
    return "0";
  }
}

String currencyNumberFormatter(dynamic p) {
  try {
    String val = p.toString();
    if (val.trim().isEmpty) {
      return "0";
    }
    final formattedVal = num.parse(num.parse(val).toStringAsFixed(2));
    return NumberFormat.decimalPattern().format(formattedVal);
  } catch (e) {
    return "0";
  }
}

String distanceConverter(double p) {
  String val = "0";
  if (p > 1000) {
    val = "${(p/1000).toStringAsFixed(2)}km";
  } else {
    val = "${p.toStringAsFixed(2)}m";
  }
  return val;
}

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

bool isValidEmail(String value) {
  // Email validation using regular expression
  // This is a simple validation, not a foolproof one
  final emailRegExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)*(\.[a-zA-Z]{2,})$');
  return emailRegExp.hasMatch(value);
}

String dateFormat(String? value, {String pattern = "dd MMM yyyy"}) {
  try {
    if (value == null) return '-';
    return DateFormat(pattern, 'id').format(DateTime.parse(value));
  } catch (error) {
    return '-';
  }
}