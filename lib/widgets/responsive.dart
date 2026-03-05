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

String formatoGuarani(double monto) {
  final partes = monto.toStringAsFixed(0).replaceAllMapped(RegExp(r"(d{1,3})(?=(d{3})+(?!d))"), (m) => "${m[1]}.").split('');
  String resultado = '';
  int contador = 0;
  for (int i = partes.length - 1; i >= 0; i--) {
    if (contador > 0 && contador % 3 == 0) {
      resultado = '.$resultado';
    }
    resultado = partes[i] + resultado;
    contador++;
  }
  return resultado;
}
