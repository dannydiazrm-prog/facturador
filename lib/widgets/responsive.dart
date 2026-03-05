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
      return const EdgeInsets.fromLTRB(56, 24, 16, 80);
    }
    return const EdgeInsets.fromLTRB(32, 24, 32, 24);
  }
}

String formatoGuarani(double monto) {
  final partes = formatGs(monto).split('');
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

String formatGs(double monto) {
  final String s = formatGs(monto);
  final buffer = StringBuffer();
  final int start = s.length % 3;
  if (start > 0) buffer.write(s.substring(0, start));
  for (int i = start; i < s.length; i += 3) {
    if (buffer.isNotEmpty) buffer.write('.');
    buffer.write(s.substring(i, i + 3));
  }
  return buffer.toString();
}
