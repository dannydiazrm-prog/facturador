import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static double paddingH(BuildContext context) =>
      isMobile(context) ? 16 : 24;

  static double sidebarWidth(BuildContext context) =>
      isMobile(context) ? 0 : 230;

  static EdgeInsets pagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.fromLTRB(16, 24, 16, 24);
    }
    return const EdgeInsets.fromLTRB(32, 24, 32, 24);
  }
}
