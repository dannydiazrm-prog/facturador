import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
<<<<<<< HEAD
=======
<<<<<<< HEAD
      MediaQuery.of(context).size.width < 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static double paddingH(BuildContext context) =>
      isMobile(context) ? 16 : 24;

  static double sidebarWidth(BuildContext context) =>
      isMobile(context) ? 0 : 230;
=======
>>>>>>> 2d434a4... fix build apk workflow
      MediaQuery.of(context).size.width < 700;

  static EdgeInsets pagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.fromLTRB(56, 24, 16, 24);
    }
    return const EdgeInsets.fromLTRB(32, 24, 32, 24);
  }
<<<<<<< HEAD
=======
>>>>>>> responsive dashboard y padding
>>>>>>> 2d434a4... fix build apk workflow
}
