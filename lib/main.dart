import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/nueva_venta.dart';
import 'screens/productos_screen.dart';
import 'screens/historial_ventas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/caja_screen.dart';
import 'services/firestore_service.dart';
import 'screens/clientes_screen.dart';
import 'screens/alertas_stock_screen.dart';
import 'screens/reporte_ventas_screen.dart';
import 'screens/reporte_inventario_screen.dart';
import 'screens/finanzas_screen.dart';
import 'screens/ajustes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facturador',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.hasData) {
      return const MainLayout();
    }
    return const LoginScreen();
  },
),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _paginaActual = 'Dashboard';
  bool _sidebarVisible = true;

  final Map<String, List<String>> _submenus = {
    'Ventas': ['Nueva Venta', 'Historial de Ventas', 'Caja', 'Clientes'],
    'Inventario': ['Productos', 'Alertas de Stock'],
    'Reportes': ['Ventas', 'Inventario'],
    'Finanzas': [],
    'Ajustes': [],
  };
  
final Map<String, IconData> _iconos = {
    'Dashboard': Icons.dashboard,
    'Ventas': Icons.receipt,
    'Inventario': Icons.inventory,
    'Reportes': Icons.bar_chart,
    'Finanzas': Icons.account_balance_wallet,
    'Ajustes': Icons.settings,
  };

  void _toggleSidebar() => setState(() => _sidebarVisible = !_sidebarVisible);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          if (_sidebarVisible)
            Container(
              width: 230,
              color: const Color(0xFF1A2744),
              child: SingleChildScrollView(
                child: Column(
                children: [
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/IMG-20260228-WA0018.jpg',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ADMINISTRADOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'Gestión e Inventario',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                  _menuSimple('Dashboard'),
                  ..._submenus.keys.map((nombre) =>
                    _submenus[nombre]!.isEmpty
                      ? _menuSimple(nombre)
                      : _menuDesplegable(nombre),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70, size: 28),
                      tooltip: 'Cerrar sesión',
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cerrar sesión'),
                            content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirmar == true) {
                          await FirebaseAuth.instance.signOut();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                ),
              ),
            ),
          Expanded(
            child: Container(
              color: const Color(0xFFF4F6FA),
              child: Stack(
                children: [
                  _buildPagina(),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF1A2744)),
                        onPressed: _toggleSidebar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagina() {
    switch (_paginaActual) {
      case 'Dashboard':
        return DashboardContent(
          onFacturar: () => setState(() => _paginaActual = 'Nueva Venta'),
        );
      case 'Nueva Venta':
        return const NuevaVentaScreen();
      case 'Historial de Ventas':
        return const HistorialVentasScreen();
      case 'Caja':
        return const CajaScreen();
      case 'Productos':
        return const ProductosScreen();
      case 'Clientes':
        return const ClientesScreen();
      case 'Alertas de Stock':
        return const AlertasStockScreen();
      case 'Ventas':
        return const ReporteVentasScreen();
      case 'Inventario':
        return const ReporteInventarioScreen();
      case 'Finanzas':
        return const FinanzasScreen();
      case 'Ajustes':
        return const AjustesScreen();
      default:
        return _paginaGenerica(_paginaActual);
    }
  }

  Widget _paginaGenerica(String titulo) {
    return Center(
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 24, color: Color(0xFF1A2744)),
      ),
    );
  }


  
  Widget _menuSimple(String nombre) {
    final activo = _paginaActual == nombre;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: activo
            ? const Color(0xFF1E88E5).withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(_iconos[nombre], color: Colors.white),
        title: Text(nombre, style: const TextStyle(color: Colors.white)),
        onTap: () => setState(() => _paginaActual = nombre),
      ),
    );
  }

  Widget _menuDesplegable(String nombre) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(_iconos[nombre], color: Colors.white),
        title: Text(nombre, style: const TextStyle(color: Colors.white)),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        childrenPadding: const EdgeInsets.only(left: 20),
        children: _submenus[nombre]!.map((sub) {
          final activo = _paginaActual == sub;
          return ListTile(
            leading: Icon(
              Icons.circle,
              size: 8,
              color: activo ? const Color(0xFF1E88E5) : Colors.white54,
            ),
            title: Text(
              sub,
              style: TextStyle(
                color: activo ? const Color(0xFF1E88E5) : Colors.white70,
                fontSize: 13,
              ),
            ),
            onTap: () => setState(() => _paginaActual = sub),
          );
        }).toList(),
      ),
    );
  }
}

Widget pageHeader(String titulo, BuildContext context) {
    final now = DateTime.now();
    final fecha = '${now.day}/${now.month}/${now.year}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),
              Text('Hoy: $fecha', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2744),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

class DashboardContent extends StatefulWidget {
  final VoidCallback onFacturar;
  const DashboardContent({super.key, required this.onFacturar});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final FirestoreService _service = FirestoreService();
  double _ventasMes = 0;
  int _totalProductos = 0;
  int _stockBajo = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1).toIso8601String();
    final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59).toIso8601String();

    // Ventas del mes
    FirebaseFirestore.instance
        .collection('ventas')
        .where('fecha', isGreaterThanOrEqualTo: inicioMes)
        .where('fecha', isLessThanOrEqualTo: finMes)
        .snapshots()
        .listen((snap) {
      double total = 0;
      for (final v in snap.docs) {
        if (v.data()['estado'] != 'anulada') {
          total += (v.data()['total'] ?? 0).toDouble();
        }
      }
      setState(() => _ventasMes = total);
    });

    // Productos y stock bajo
    FirebaseFirestore.instance
        .collection('productos')
        .where('esServicio', isEqualTo: false)
        .snapshots()
        .listen((snap) {
      int stockBajo = 0;
      for (final p in snap.docs) {
        if ((p.data()['stock'] ?? 0) <= (p.data()['stockMinimo'] ?? 0)) {
          stockBajo++;
        }
      }
      setState(() {
        _totalProductos = snap.docs.length;
        _stockBajo = stockBajo;
        _cargando = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(56, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeader('BIENVENIDO BN24py', context),
          Row(
            children: [
              Expanded(child: _tarjeta('Ventas del Mes', _cargando ? '...' : 'Gs. ${_ventasMes.toStringAsFixed(0)}', Icons.trending_up, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _tarjeta('Stock Bajo', _cargando ? '...' : '$_stockBajo', Icons.warning, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _tarjeta('Productos', _cargando ? '...' : '$_totalProductos', Icons.inventory, Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _cardUltimasVentas()),
              const SizedBox(width: 16),
              Expanded(child: _cardFacturar()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(String titulo, String valor, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icono, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                  Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaGrid(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardUltimasVentas() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimas Ventas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A2744),
            ),
          ),
          const Divider(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ventas')
                .orderBy('fecha', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Text(
                  'Aún no hay ventas registradas.',
                  style: TextStyle(color: Colors.grey),
                );
              }
              return Column(
                children: snap.data!.docs.map((doc) {
                  final v = doc.data() as Map<String, dynamic>;
                  final fecha = DateTime.parse(v['fecha']);
                  final anulada = v['estado'] == 'anulada';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: anulada
                          ? Colors.red.withOpacity(0.05)
                          : const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: anulada
                            ? Colors.red.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v['clienteNombre'] ?? 'Cliente',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Gs. ${(v['total'] ?? 0).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: anulada
                                    ? Colors.red
                                    : const Color(0xFF1E88E5),
                              ),
                            ),
                            if (anulada)
                              const Text(
                                'ANULADA',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cardFacturar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, size: 60, color: Color(0xFF1E88E5)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: widget.onFacturar,
              child: const Text(
                'FACTURAR AHORA',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}