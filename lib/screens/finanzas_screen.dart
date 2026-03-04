import '../widgets/responsive.dart';
import "../widgets/page_header.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  final FirestoreService _service = FirestoreService();
  String _periodoSeleccionado = 'Mes';
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  Future<void> _seleccionarFecha(bool esDesde) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        if (esDesde) _fechaDesde = fecha;
        else _fechaHasta = fecha;
      });
    }
  }

  bool _enPeriodo(String fechaStr) {
    final fecha = DateTime.parse(fechaStr);
    final ahora = DateTime.now();
    if (_periodoSeleccionado == 'Hoy') {
      return fecha.day == ahora.day &&
          fecha.month == ahora.month &&
          fecha.year == ahora.year;
    } else if (_periodoSeleccionado == 'Semana') {
      final inicioSemana =
          ahora.subtract(Duration(days: ahora.weekday - 1));
      return fecha.isAfter(
          inicioSemana.subtract(const Duration(days: 1)));
    } else if (_periodoSeleccionado == 'Mes') {
      return fecha.month == ahora.month && fecha.year == ahora.year;
    } else if (_periodoSeleccionado == 'Personalizado') {
      if (_fechaDesde != null &&
          fecha.isBefore(_fechaDesde!)) return false;
      if (_fechaHasta != null &&
          fecha.isAfter(
              _fechaHasta!.add(const Duration(days: 1)))) return false;
      return true;
    }
    return true;
  }

  void _mostrarAgregarGasto() {
    final montoCtrl = TextEditingController();
    final descripCtrl = TextEditingController();
    String categoria = 'Insumos';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.remove_circle,
                            color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'NUEVO GASTO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2744),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Categoría
              const Text(
                'Categoría',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2744),
                    fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Insumos', 'Salario', 'Servicios', 'Otros']
                    .map((cat) {
                  final sel = categoria == cat;
                  return GestureDetector(
                    onTap: () => setModalState(() => categoria = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Descripción
              TextField(
                controller: descripCtrl,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Descripción *',
                  prefixIcon: const Icon(Icons.description,
                      color: Color(0xFF1E88E5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF1E88E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Monto
              TextField(
                controller: montoCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Monto (Gs.) *',
                  prefixIcon: const Icon(Icons.attach_money,
                      color: Color(0xFF1E88E5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF1E88E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (descripCtrl.text.trim().isEmpty ||
                        montoCtrl.text.trim().isEmpty) return;
                    await _service.agregarGasto({
                      'fecha': DateTime.now().toIso8601String(),
                      'categoria': categoria,
                      'descripcion': descripCtrl.text.trim(),
                      'monto': double.parse(montoCtrl.text.trim()),
                      'automatico': false,
                    });
                    Navigator.pop(context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'GUARDAR GASTO',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarAgregarCapital() {
    final montoCtrl = TextEditingController();
    final descripCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.add_circle, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'INYECTAR CAPITAL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2744),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: descripCtrl,
              maxLength: 50,
              decoration: InputDecoration(
                labelText: 'Descripción *',
                prefixIcon: const Icon(Icons.description,
                    color: Color(0xFF1E88E5)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Monto (Gs.) *',
                prefixIcon: const Icon(Icons.attach_money,
                    color: Color(0xFF1E88E5)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (descripCtrl.text.trim().isEmpty ||
                      montoCtrl.text.trim().isEmpty) return;
                  await _service.agregarCapital({
                    'fecha': DateTime.now().toIso8601String(),
                    'descripcion': descripCtrl.text.trim(),
                    'monto': double.parse(montoCtrl.text.trim()),
                  });
                  Navigator.pop(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'GUARDAR CAPITAL',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _ventasPorMes(List<Map<String, dynamic>> ventas) {
    final Map<String, double> resultado = {};
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    for (final v in ventas) {
      final fecha = DateTime.parse(v['fecha']);
      final clave = meses[fecha.month - 1];
      resultado[clave] = (resultado[clave] ?? 0) + (v['total'] ?? 0).toDouble();
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ventas')
          .where('estado', isNotEqualTo: 'anulada')
          .snapshots(),
      builder: (context, snapVentas) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _service.getGastos(),
          builder: (context, snapGastos) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _service.getCapital(),
              builder: (context, snapCapital) {
                if (snapVentas.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Ventas del período
                final todasVentas = snapVentas.data?.docs
                        .map((d) => d.data() as Map<String, dynamic>)
                        .toList() ?? [];
                final ventasPeriodo = todasVentas
                    .where((v) => _enPeriodo(v['fecha']))
                    .toList();
                final totalIngresos = ventasPeriodo.fold(
                    0.0, (sum, v) => sum + (v['total'] ?? 0).toDouble());

                // Gastos del período
                final todosGastos = snapGastos.data ?? [];
                final gastosPeriodo = todosGastos
                    .where((g) => _enPeriodo(g['fecha']))
                    .toList();
                final totalGastos = gastosPeriodo.fold(
                    0.0, (sum, g) => sum + (g['monto'] ?? 0).toDouble());

                // Capital del período
                final todoCapital = snapCapital.data ?? [];
                final capitalPeriodo = todoCapital
                    .where((c) => _enPeriodo(c['fecha']))
                    .toList();
                final totalCapital = capitalPeriodo.fold(
                    0.0, (sum, c) => sum + (c['monto'] ?? 0).toDouble());

                final resultado = totalIngresos + totalCapital - totalGastos;
                final ganando = resultado >= 0;

                // Datos gráfico por mes
                final ventasMes = _ventasPorMes(todasVentas);
                final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

                return SingleChildScrollView(
                  padding: const Responsive.pagePadding(context),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  padding: const Responsive.pagePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                            pageHeader('FINANZAS', context),


                      // Selector período
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Período',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2744)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: ['Hoy', 'Semana', 'Mes', 'Personalizado']
                                  .map((p) {
                                final sel = _periodoSeleccionado == p;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _periodoSeleccionado = p),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: sel
                                            ? const Color(0xFF1E88E5)
                                            : const Color(0xFFF4F6FA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: sel
                                              ? const Color(0xFF1E88E5)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        p,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: sel
                                              ? Colors.white
                                              : Colors.grey,
                                             fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (_periodoSeleccionado == 'Personalizado') ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _seleccionarFecha(true),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 16,
                                                color: Color(0xFF1E88E5)),
                                            const SizedBox(width: 8),
                                            Text(
                                              _fechaDesde != null
                                                  ? '${_fechaDesde!.day}/${_fechaDesde!.month}/${_fechaDesde!.year}'
                                                  : 'Desde',
                                              style: TextStyle(
                                                color: _fechaDesde != null
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _seleccionarFecha(false),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 16,
                                                color: Color(0xFF1E88E5)),
                                            const SizedBox(width: 8),
                                            Text(
                                              _fechaHasta != null
                                                  ? '${_fechaHasta!.day}/${_fechaHasta!.month}/${_fechaHasta!.year}'
                                                  : 'Hasta',
                                              style: TextStyle(
                                                color: _fechaHasta != null
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resultado principal
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ganando ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              ganando
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ganando ? '¡ESTÁS GANANDO!' : 'ESTÁS PERDIENDO',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gs. ${resultado.abs().toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tarjetas ingresos gastos capital
                      Row(
                        children: [
                          _tarjeta(
                            titulo: 'Ingresos',
                            valor: 'Gs. ${totalIngresos.toStringAsFixed(0)}',
                            icono: Icons.arrow_upward,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _tarjeta(
                            titulo: 'Gastos',
                            valor: 'Gs. ${totalGastos.toStringAsFixed(0)}',
                            icono: Icons.arrow_downward,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _tarjetaAncha(
                        titulo: 'Capital Inyectado',
                        valor: 'Gs. ${totalCapital.toStringAsFixed(0)}',
                        icono: Icons.account_balance,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),

                      // Gráfico comparativo por mes
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ventas por mes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2744),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: ventasMes.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No hay datos aún',
                                        style:
                                            TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : BarChart(
                                      BarChartData(
                                        gridData:
                                            const FlGridData(show: false),
                                        borderData:
                                            FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget:
                                                  (value, meta) {
                                                final idx = value.toInt();
                                                if (idx < 0 ||
                                                    idx >= meses.length) {
                                                  return const Text('');
                                                }
                                                return Text(
                                                  meses[idx],
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        barGroups: meses
                                            .asMap()
                                            .entries
                                            .map((e) => BarChartGroupData(
                                                  x: e.key,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: ventasMes[
                                                              e.value] ??
                                                          0,
                                                      color: const Color(
                                                          0xFF1E88E5),
                                                      width: 16,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(4),
                                                    ),
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botones agregar
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _mostrarAgregarGasto,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Agregar Gasto',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _mostrarAgregarCapital,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Inyectar Capital',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Lista gastos del período
                      if (gastosPeriodo.isNotEmpty) ...[
                        const Text(
                          'GASTOS DEL PERÍODO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2744),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: gastosPeriodo.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (context, index) {
                              final g = gastosPeriodo[index];
                              final fecha =
                                  DateTime.parse(g['fecha']);
                              final automatico =
                                  g['automatico'] ?? false;
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.red.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    automatico
                                        ? Icons.inventory
                                        : Icons.receipt_long,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  g['descripcion'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${g['categoria']} | ${fecha.day}/${fecha.month}/${fecha.year}${automatico ? ' · Automático' : ''}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Gs. ${(g['monto'] ?? 0).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!automatico)
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.grey,
                                            size: 20),
                                        onPressed: () =>
                                            _service.eliminarGasto(
                                                g['id']),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                                         // Lista capital del período
                      if (capitalPeriodo.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'CAPITAL INYECTADO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2744),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: capitalPeriodo.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (context, index) {
                              final c = capitalPeriodo[index];
                              final fecha =
                                  DateTime.parse(c['fecha']);
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.blue.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.account_balance,
                                      color: Colors.blue,
                                      size: 20),
                                ),
                                title: Text(
                                  c['descripcion'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${fecha.day}/${fecha.month}/${fecha.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Gs. ${(c['monto'] ?? 0).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.grey,
                                          size: 20),
                                      onPressed: () =>
                                          _service.eliminarCapital(
                                              c['id']),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _tarjeta({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                  Text(valor,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaAncha({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(valor,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}