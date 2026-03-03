import "../widgets/page_header.dart";
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';
import 'producto_form.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final FirestoreService _service = FirestoreService();
  final _buscarCtrl = TextEditingController();
  String _filtro = '';
  String _tipoFiltro = 'Todos';

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  void _abrirFormulario({Producto? producto}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductoForm(productoExistente: producto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(56, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // Header
          pageHeader(
            'PRODUCTOS',
            context,
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nuevo Producto',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _buscarCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre o código',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF1E88E5)),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _filtro = v.toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['Todos', 'Productos', 'Servicios'].map((tipo) {
                    final seleccionado = _tipoFiltro == tipo;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _tipoFiltro = tipo),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: seleccionado
                                ? const Color(0xFF1E88E5)
                                : const Color(0xFFF4F6FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: seleccionado
                                  ? const Color(0xFF1E88E5)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            tipo,
                            style: TextStyle(
                              color: seleccionado ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de productos
          StreamBuilder<List<Producto>>(
            stream: _service.getProductos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay productos aún',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toca "Nuevo Producto" para agregar',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              var productos = snapshot.data!;

              // Aplicar filtros
              if (_filtro.isNotEmpty) {
                productos = productos
                    .where((p) =>
                        p.nombre.toLowerCase().contains(_filtro) ||
                        p.codigo.toLowerCase().contains(_filtro))
                    .toList();
              }
              if (_tipoFiltro == 'Productos') {
                productos = productos.where((p) => !p.esServicio).toList();
              } else if (_tipoFiltro == 'Servicios') {
                productos = productos.where((p) => p.esServicio).toList();
              }

              if (productos.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No se encontraron resultados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productos.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final p = productos[index];
                    final alertaStock =
                        !p.esServicio && p.stock <= p.stockMinimo;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: p.esServicio
                              ? Colors.purple.withOpacity(0.1)
                              : const Color(0xFF1E88E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          p.esServicio ? Icons.build : Icons.inventory_2,
                          color: p.esServicio
                              ? Colors.purple
                              : const Color(0xFF1E88E5),
                          size: 22,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            p.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (alertaStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Stock bajo',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        'Código: ${p.codigo} | ${p.esServicio ? "Servicio" : "Stock: ${p.stock}"}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Gs. ${p.precio.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                          if (!p.esServicio)
                            Text(
                              'Compra: Gs. ${p.precioCompra.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                        ],
                      ),
                      onTap: () => _abrirFormulario(producto: p),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
