import 'dart:async';
import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:bea_service_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ChecadorScreen extends ConsumerStatefulWidget {
  const ChecadorScreen({super.key});

  @override
  ConsumerState<ChecadorScreen> createState() => _ChecadorScreenState();
}

class _ChecadorScreenState extends ConsumerState<ChecadorScreen> {
  bool _isLoading = false;
  
  // --- VARIABLES DEL RELOJ ---
  DateTime _horaActual = DateTime.now();
  Timer? _timer;

  // --- VARIABLES DE GEOLOCALIZACIÓN Y MAPA ---
  GoogleMapController? _mapController;
  Position? _ubicacionActual;
  bool _obteniendoUbicacion = true;
  bool _dentroDeGeocerca = false;

   double _geocercaLat = 0.0;
   double _geocercaLng = 0.0;
   double _radioPermitidoMetros = 0.0; 

  @override
  void initState() {
    super.initState();
    // Iniciar reloj
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _horaActual = DateTime.now());
    });
    
    // Iniciar búsqueda de GPS
    _determinarUbicacion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Helpers de tiempo (Los que ya tenías con AM/PM)
  String _formatearHora(DateTime time) {
    final periodo = time.hour >= 12 ? 'PM' : 'AM';
    int hora12 = time.hour % 12;
    if (hora12 == 0) hora12 = 12;
    return "${hora12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')} $periodo";
  }
  String _formatearFecha(DateTime time) => "${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}";

  // ====================================================================
  // MAGIA DEL GPS Y GEOCERCA
  // ====================================================================
  Future<void> _determinarUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Validar GPS y permisos (Igual que antes)
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _mostrarErrorGPS('El servicio de ubicación está desactivado.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _mostrarErrorGPS('Permisos de ubicación denegados.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _mostrarErrorGPS('Los permisos de ubicación están denegados permanentemente.');
      return;
    }

    // 2. Obtener la ubicación actual del celular
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // =================================================================
    // 3. EXTRAER DATOS DEL BACKEND (NUEVO)
    // =================================================================
    // Leemos el provider tal como lo haces en tu build
    final usuario = ref.read(authStateProvider).valueOrNull;
    final geocerca = usuario?['geocerca'];

    if (geocerca != null) {
      final String coordenadasStr = geocerca['coordenada'];
      
      final List<String> partes = coordenadasStr.split(',');
      _geocercaLat = double.parse(partes[0].trim());
      _geocercaLng = double.parse(partes[1].trim());
      _radioPermitidoMetros = (geocerca['radio'] as num).toDouble();

    } else {
      _mostrarErrorGPS('No se encontró una geocerca asignada.');
      return;
    }

    // 4. Calcular distancia matemática a la oficina
    double distancia = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _geocercaLat,
      _geocercaLng,
    );

    // 5. Actualizar la pantalla
    if (mounted) {
      setState(() {
        _ubicacionActual = position;
        _obteniendoUbicacion = false;
        _dentroDeGeocerca = distancia <= _radioPermitidoMetros;
      });

      // Mover la cámara del mapa a la ubicación asignada en el backend
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16.0, // Zoom intermedio
        ),
      );
    }
  }

  void _mostrarErrorGPS(String mensaje) {
    if (mounted) {
      setState(() => _obteniendoUbicacion = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: Colors.red));
    }
  }

  // --- BOTÓN CHECAR ---
  Future<void> _registrarChecada() async {
    if (!_dentroDeGeocerca) return; // Doble candado de seguridad
    setState(() => _isLoading = true);

    try {
      // AQUÍ: Le mandas a NestJS la hora y también las coordenadas reales del empleado
      // para que queden guardadas en su registro.
      // await ref.read(asistenciaControllerProvider).registrarChecada(
      //   lat: _ubicacionActual!.latitude, 
      //   lng: _ubicacionActual!.longitude,
      // );
      
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Registro guardado a las ${_formatearHora(_horaActual)}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Manejo de error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authStateProvider).valueOrNull;
    final nombreUsuario = usuario?['nombre'] ?? 'Cargando...';
    final puestoUsuario = usuario?['perfil']?.toString().toUpperCase() ?? 'EMPLEADO';    final colorPrimario = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Checador')),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================================================
              // MAPA INTERACTIVO
              // =========================================================
              
              Container(
                height: 250, // Lo hice un poco más alto para que se aprecie mejor
                color: Colors.grey.shade300,
                child: _obteniendoUbicacion
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Obteniendo tu ubicación precisa...'),
                          ],
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _ubicacionActual?.latitude ?? _geocercaLat,
                            _ubicacionActual?.longitude ?? _geocercaLng,
                          ),
                          zoom: 14,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        myLocationEnabled: true, // Muestra el puntito azul de Google
                        myLocationButtonEnabled: true, // Botón para centrar
                        zoomControlsEnabled: false,
                        
                        // DIBUJAMOS LA GEOCERCA
                        
                        circles: {
                          Circle(
                            circleId: const CircleId('geocerca_oficina'),
                            center: LatLng(_geocercaLat, _geocercaLng),
                            radius: _radioPermitidoMetros,
                            // Si está dentro pintamos la zona verde, si no, roja
                            fillColor: _dentroDeGeocerca 
                                ? Colors.green.withOpacity(0.2) 
                                : Colors.red.withOpacity(0.2),
                            strokeColor: _dentroDeGeocerca ? Colors.green : Colors.red,
                            strokeWidth: 2,
                          ),
                        },
                      ),
              ),

              // =========================================================
              // MENSAJE DE VALIDACIÓN (Nuevo)
              // =========================================================
              if (!_obteniendoUbicacion)
                Container(
                  color: _dentroDeGeocerca ? Colors.green.shade50 : Colors.red.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        _dentroDeGeocerca ? Icons.check_circle : Icons.warning,
                        color: _dentroDeGeocerca ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dentroDeGeocerca 
                              ? 'Estás en la zona permitida.'
                              : 'Estás fuera de la zona de registro. Acércate a la oficina.',
                          style: TextStyle(
                            color: _dentroDeGeocerca ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // --- INFORMACIÓN DEL USUARIO Y RELOJ ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(nombreUsuario, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(puestoUsuario, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider()),
                    
                    // RELOJ
                    Icon(Icons.access_time_filled, size: 40, color: colorPrimario),
                    Text(
                      _formatearHora(_horaActual),
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: colorPrimario),
                    ),
                    Text(_formatearFecha(_horaActual), style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                    const SizedBox(height: 36),

                    // --- BOTÓN CONDICIONADO ---
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        // SI NO ESTÁ EN LA ZONA, DESHABILITAMOS EL BOTÓN (poniéndolo en null)
                        onPressed: (_isLoading || !_dentroDeGeocerca || _obteniendoUbicacion) 
                            ? null 
                            : _registrarChecada,
                        icon: _isLoading 
                            ? const SizedBox.shrink() 
                            : const Icon(Icons.fingerprint, size: 28),
                        label: _isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('CHECAR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        style: ElevatedButton.styleFrom(
                          // Cuando está deshabilitado, Flutter lo pinta gris automáticamente
                          backgroundColor: const Color(0xFF00B140), 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}