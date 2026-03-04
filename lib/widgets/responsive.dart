import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  static EdgeInsets pagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.fromLTRB(56, 24, 16, 24);
    }
    return const EdgeInsets.fromLTRB(32, 24, 32, 24);
  }
}
