import 'package:intl/intl.dart' as intl;
import 'package:trina_grid/src/helper/trina_general_helper.dart';

mixin TrinaColumnTypeWithNumberFormat {
  intl.NumberFormat get numberFormat;

  bool get negative;

  int get decimalPoint;

  bool get allowFirstDot;

  String? get locale;

  bool isValid(dynamic value) {
    if (!isNumeric(value)) {
      return false;
    }

    if (negative == false && num.parse(value.toString()) < 0) {
      return false;
    }

    return true;
  }

  int compare(dynamic a, dynamic b) {
    return TrinaGeneralHelper.compareWithNull(
      a,
      b,
      () => toNumber(a.toString()).compareTo(toNumber(b.toString())),
    );
  }

  dynamic makeCompareValue(dynamic v) {
    return v.runtimeType != num ? num.tryParse(v.toString()) ?? 0 : v;
  }

  String applyFormat(dynamic value) {
    num number =
        num.tryParse(
          value.toString().replaceAll(numberFormat.symbols.DECIMAL_SEP, '.'),
        ) ??
        0;

    if (negative == false && number < 0) {
      number = 0;
    }

    return numberFormat.format(number);
  }

  /// Convert [String] converted to [applyFormat] to [number].
  dynamic toNumber(String formatted) {
    String match = '0-9\\-${numberFormat.symbols.DECIMAL_SEP}';

    if (negative) {
      match += numberFormat.symbols.MINUS_SIGN;
    }

    formatted = formatted
        .replaceAll(RegExp('[^$match]'), '')
        .replaceFirst(numberFormat.symbols.DECIMAL_SEP, '.');

    final num formattedNumber = num.tryParse(formatted) ?? 0;

    return formattedNumber.isFinite ? formattedNumber : 0;
  }

  bool isNumeric(dynamic s) {
    if (s == null) {
      return false;
    }
    return num.tryParse(s.toString()) != null;
  }
}
