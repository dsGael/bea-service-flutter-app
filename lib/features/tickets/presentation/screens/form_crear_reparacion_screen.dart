import 'dart:convert';
import 'dart:io';
import 'package:bea_service_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bea_service_app/features/tickets/data/models/diagnostico_model.dart';
import 'package:bea_service_app/features/tickets/data/models/ticket_model.dart';
import 'package:bea_service_app/features/tickets/data/uploads_repository.dart';
import 'package:bea_service_app/features/tickets/presentation/providers/tickets_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReparacionFormScreen extends ConsumerStatefulWidget {
  final TicketModel ticket;
  const ReparacionFormScreen({super.key, required this.ticket});

  @override
  ConsumerState<ReparacionFormScreen> createState() => _ReparacionFormScreenState();
}

class _ReparacionFormScreenState extends ConsumerState<ReparacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _comentariosController = TextEditingController();
  final _picker = ImagePicker();

  DateTime _fechaAtencion = DateTime.now();
  bool _cargandoCatalogos = false;
  bool _guardando = false;

  // Catálogo
  List<DiagnosticoModel> _catalogoDiagnosticos = [];
  
  // Diagnósticos únicos
  List<String> get _diagnosticosUnicos =>
      _catalogoDiagnosticos.map((d) => d.diagnostico).toSet().toList()..sort();
      
  // Reparaciones dinámicas (Lógica de AppSheet replicada)
  List<String> get _reparacionesDisponibles {
    if (_diagnosticoSeleccionado == null || _diagnosticoSeleccionado!.isEmpty) {
      // Si está en blanco, muestra TODAS las reparaciones de ese dispositivo
      return _catalogoDiagnosticos
          .where((d) => d.reparacion != null)
          .map((d) => d.reparacion!)
          .toSet()
          .toList()
        ..sort();
    }
    // Si hay un diagnóstico seleccionado, filtra estrictamente
    return _catalogoDiagnosticos
        .where((d) => d.diagnostico == _diagnosticoSeleccionado && d.reparacion != null)
        .map((d) => d.reparacion!)
        .toSet()
        .toList()
      ..sort();
  }

  String? _diagnosticoSeleccionado;
  String? _reparacionSeleccionada;

  // Evidencias (Arreglo ilimitado)
  List<File> _evidencias = [];

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

Future<void> _cargarCatalogos() async {
    final idFalla = widget.ticket.falla?.idFalla;
    if (idFalla == null) return;

    setState(() => _cargandoCatalogos = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get(
        '/catalogos/diagnostico/falla',
        queryParameters: {'idFalla': idFalla},
      );

      // 1. Tomamos la data sin forzarla a "as List" todavía
      final rawData = apiClient.unwrap(response); 

      // 👇 2. ESTO TE DIRÁ EXACTAMENTE QUÉ ESTÁ MANDANDO NESTJS 👇
      print('=== RESPUESTA DEL BACKEND ===');
      print('TIPO: ${rawData.runtimeType}');
      print('VALOR: $rawData');
      print('=============================');

      List<dynamic> listaSegura = [];

      // 3. Lógica a prueba de balas para extraer la lista
      if (rawData is List) {
        // Escenario ideal: Llegó como una lista real
        listaSegura = rawData;
      } else if (rawData is String) {
        // Escenario B: Llegó como un texto, intentamos decodificarlo a JSON
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is List) {
            listaSegura = decoded;
          } else if (decoded is Map) {
            // Por si viene envuelto como { "data": [...] }
            listaSegura = decoded['data'] ?? decoded.values.firstWhere((v) => v is List, orElse: () => []);
          }
        } catch (e) {
          throw Exception('El servidor devolvió un texto plano que no es JSON: $rawData');
        }
      } else if (rawData is Map) {
        // Escenario C: Llegó como un mapa de Dart { "data": [...] }
        listaSegura = rawData['data'] ?? rawData.values.firstWhere((v) => v is List, orElse: () => []);
      } else {
        throw Exception('Formato de respuesta desconocido.');
      }

      // 4. Mapeamos la lista segura a nuestro modelo
      setState(() {
        _catalogoDiagnosticos = listaSegura
            .map((j) => DiagnosticoModel.fromJson(j as Map<String, dynamic>))
            .toList();
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar catálogos: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _cargandoCatalogos = false);
    }
  }

  Future<void> _seleccionarEvidencia() async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, 'foto-camara'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir foto de galería'),
              onTap: () => Navigator.pop(context, 'foto-galeria'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Grabar video'),
              onTap: () => Navigator.pop(context, 'video-camara'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Elegir video de galería'),
              onTap: () => Navigator.pop(context, 'video-galeria'),
            ),
          ],
        ),
      ),
    );

    if (opcion == null) return;

    final isVideo = opcion.startsWith('video');
    final source = opcion.endsWith('camara') ? ImageSource.camera : ImageSource.gallery;

    if (isVideo) {
      final picked = await _picker.pickVideo(source: source);
      if (picked != null && mounted) {
        setState(() {
          _evidencias.add(File(picked.path));
        });
      }
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1280,
    );

    if (picked != null && mounted) {
      setState(() {
        _evidencias.add(File(picked.path));
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaAtencion,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaAtencion),
    );
    if (hora == null) return;

    setState(() {
      _fechaAtencion = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    });
  }

  Future<void> _guardarReparacion() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar que se haya seleccionado al menos una evidencia si es obligatorio
    // if (_evidencias.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Por favor adjunta al menos una evidencia')),
    //   );
    //   return;
    // }

    setState(() => _guardando = true);

    try {
      final String fechaOffline = DateTime.now().toUtc().toIso8601String();

      await ref.read(ticketsControllerProvider).registrarReparacion(
        idTicket: widget.ticket.idticket,
        diagnostico: _diagnosticoSeleccionado ?? '',
        reparacion: _reparacionSeleccionada ?? '',
        comentarios: _comentariosController.text.trim(),
        fechaHora: fechaOffline, 
        evidencias: _evidencias.isNotEmpty ? _evidencias : null, // Pasamos la lista de Files directo
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reparación registrada — en espera de validación'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        String mensajeError = 'Error al guardar';
        
        // Si el error viene de Dio, extraemos la respuesta del backend
        if (e is DioException && e.response != null) {
          final data = e.response!.data;
          print('🚨 RECHAZO DEL BACKEND: $data'); // Se verá en tu consola de Flutter
          
          // NestJS suele mandar los errores de validación en un arreglo llamado 'message'
          if (data is Map && data.containsKey('message')) {
            final msj = data['message'];
            mensajeError = msj is List ? msj.join(', ') : msj.toString();
          } else {
            mensajeError = 'Error 400: Datos inválidos enviados al servidor';
          }
        } else {
          mensajeError = e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5), // Un poco más de tiempo para leer
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Reparación')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Fecha de Atención *'),
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy hh:mm a').format(_fechaAtencion)),
                ),
              ),
              const SizedBox(height: 20),

              _label('Falla Reportada'),
              TextFormField(
                initialValue: widget.ticket.falla?.falla ?? widget.ticket.comentarios ?? 'Sin falla registrada',
                readOnly: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),

              _label('Diagnóstico'),
              _cargandoCatalogos
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _diagnosticoSeleccionado,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('Seleccione...'),
                      isExpanded: true,
                      items: _diagnosticosUnicos
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _diagnosticoSeleccionado = value;
                          // Valida que la reparación actual siga existiendo tras el nuevo filtro
                          if (_reparacionSeleccionada != null && 
                              !_reparacionesDisponibles.contains(_reparacionSeleccionada)) {
                            _reparacionSeleccionada = null; 
                          }
                        });
                      },
                      // Ya no es requerido estricto si quieres emular AppSheet puro, 
                      // pero puedes dejar el validator si es obligatorio.
                    ),
              const SizedBox(height: 20),

              _label('Reparación *'),
              DropdownButtonFormField<String>(
                value: _reparacionSeleccionada,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Seleccione...'),
                isExpanded: true,
                items: _reparacionesDisponibles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) => setState(() => _reparacionSeleccionada = value),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              _label('Comentarios'),
              TextFormField(
                controller: _comentariosController,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // SECCIÓN DE EVIDENCIAS ILIMITADAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Evidencias Adjuntas (${_evidencias.length})'),
                  TextButton.icon(
                    onPressed: _seleccionarEvidencia,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Agregar'),
                  )
                ],
              ),
              const SizedBox(height: 8),
              
              if (_evidencias.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('No hay archivos adjuntos', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _evidencias.length,
                    itemBuilder: (context, index) {
                      final archivo = _evidencias[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _buildBotonEvidencia(
                          archivo: archivo,
                          onEliminar: () {
                            setState(() {
                              _evidencias.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _guardando ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarReparacion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2396B9),
                    foregroundColor: Colors.white,
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(texto,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      );

  // Tarjeta de miniatura para la lista horizontal
  Widget _buildBotonEvidencia({
    required File archivo,
    required VoidCallback onEliminar,
  }) {
    final esVideo = _esVideo(archivo);

    return Container(
      width: 120,
      height: 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        image: !esVideo
            ? DecorationImage(image: FileImage(archivo), fit: BoxFit.cover)
            : null,
        color: Colors.grey.shade900, // Fondo negro para videos
      ),
      child: Stack(
        children: [
          if (esVideo)
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, size: 36, color: Colors.white),
                  const SizedBox(height: 6),
                  Text('Video', style: TextStyle(color: Colors.grey.shade100, fontSize: 12)),
                ],
              ),
            ),
          Positioned(
            top: -4, 
            right: -4,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
              onPressed: onEliminar,
            ),
          ),
        ],
      ),
    );
  }

  bool _esVideo(File? archivo) {
    if (archivo == null) return false;
    final ext = archivo.path.split('.').last.toLowerCase();
    return {'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'}.contains(ext);
  }
}