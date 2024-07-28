import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_snackbar.dart';

extension AppSizeBoxExtension on int {
  Widget get height => SizedBox(height: toDouble().h);
  Widget get width => SizedBox(width: toDouble().w);
  Widget get sph => SizedBox(height: toDouble().sp);
  Widget get spw => SizedBox(width: toDouble().sp);
  Widget get screenHeight => SizedBox(height: toDouble().sh);
  Widget get screenWidth => SizedBox(width: toDouble().sw);
}

///// On String /////

extension Capitalize on String {
  String get capitalize {
    if (isEmpty) {
      return this;
    }

    List<String> words = split(' ');

    List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return '';
      }
    }).toList();

    String camelCaseString = capitalizedWords.join(' ');

    return camelCaseString;
  }

  String short(int length) {
    if (this.length < 2 * length + 4) {
      // If the length of the address is shorter than the required length, return the original address.
      return this;
    }
    return '${substring(0, length + 2)}****s${substring(this.length - length)}';
  }

  double toDouble() {
    return double.tryParse(this) ?? 0;
  }

  DateTime get toDate => DateTime.parse(this);
}

extension ListFirstWhereOrNullExtension<T> on List<T> {
  /// Returns the first element that matches [test], or `null` if no element is found.
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}

extension CustomContext on BuildContext {
  void setClipboard({required String text, bool showSnackBar = true}) =>
      Clipboard.setData(ClipboardData(text: text)).then((value) {
        if (showSnackBar) {
          CustomSnackbar.showSnackbar(this, 'Copied $text');
        }
      });

  void showSnackBar(String text) {
    CustomSnackbar.showSnackbar(this, text);
  }
}
