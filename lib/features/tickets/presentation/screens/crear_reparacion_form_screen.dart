import 'dart:math';

import 'package:bea_service_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
// Importa tu TicketModel y providers
import 'package:bea_service_app/features/tickets/data/models/ticket_model.dart';
import 'package:uuid/uuid.dart';

class ReparacionFormScreen extends ConsumerStatefulWidget {
  final TicketModel ticket;

  const ReparacionFormScreen({super.key, required this.ticket});

  @override
  ConsumerState<ReparacionFormScreen> createState() => _ReparacionFormScreenState();
}

class _ReparacionFormScreenState extends ConsumerState<ReparacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores y variables de estado
  DateTime _fechaAtencion = DateTime.now();
  String? _diagnosticoSeleccionado;
  String? _reparacionSeleccionada;
  final _comentariosController = TextEditingController();

  // Listas simuladas (Estas se llenarán llamando a tu API de NestJS)
  List<String> _listaDiagnosticos = [];
  List<String> _listaReparaciones = [];
  bool _cargandoCatalogos = false;

  @override
  void initState() {
    super.initState();
    _cargarDiagnosticos();
  }

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE API (Simulada) ---
  Future<void> _cargarDiagnosticos() async {
    setState(() => _cargandoCatalogos = true);
    
    // Aquí el ID del dispositivo heredado. Si no tiene directo, lo saca de la falla.
    final idDispositivo = widget.ticket.dispositivo?.idDispositivoT ?? widget.ticket.falla?.idFalla;

    // TODO: Llamar a tu API GET /catalogos/diagnosticos?idDispositivo=$idDispositivo
    await Future.delayed(const Duration(milliseconds: 500)); // Simulando red
    
    setState(() {
      _listaDiagnosticos = ['Falso Contacto', 'Cortocircuito', 'Daño Físico', 'Desconfiguración'];
      _cargandoCatalogos = false;
    });
  }

  Future<void> _cargarReparaciones(String diagnostico) async {
    setState(() {
      _cargandoCatalogos = true;
      _reparacionSeleccionada = null; // Limpiar la reparación actual al cambiar diagnóstico
    });

    // TODO: Llamar a tu API GET /catalogos/reparaciones?idDispositivo=$idDispositivo&diagnostico=$diagnostico
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      // Simulación basada en el diagnóstico
      if (diagnostico == 'Falso Contacto') {
        _listaReparaciones = ['Limpieza de pines', 'Ajuste de arnés', 'Reemplazo de cable'];
      } else {
        _listaReparaciones = ['Reemplazo de pieza', 'Reinicio de sistema'];
      }
      _cargandoCatalogos = false;
    });
  }

  // --- LÓGICA DE UI ---
  Future<void> _seleccionarFecha() async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaAtencion,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (seleccion != null) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaAtencion),
      );
      if (hora != null) {
        setState(() {
          _fechaAtencion = DateTime(
            seleccion.year, seleccion.month, seleccion.day,
            hora.hour, hora.minute,
          );
        });
      }
    }
  }

  Future<void> _guardarReparacion() async {
    if (_formKey.currentState!.validate()) {
      // 1. Obtener el técnico logueado sin preguntarle al usuario en la UI
      final usuario = ref.read(authStateProvider).valueOrNull;
      final idTecnico = usuario?['idUsuarioApp'] ?? 'Desconocido';
      final idGeneradoLocalmente = const Uuid().v4(); // Creas el ID
      // 2. Armar el payload para NestJS
      final payload = {
        'idticket': widget.ticket.idticket,
        'idDetalleTicket': idGeneradoLocalmente, // Genera un ID único para el detalle de ticket
        'idtecnico': idTecnico,
        'fechaAtencion': _fechaAtencion.toIso8601String(),
        'diagnostico': _diagnosticoSeleccionado,
        'reparacion': _reparacionSeleccionada,
        'comentarios': _comentariosController.text,
        // Aquí irían las URLs de las fotos subidas a S3 o Firebase
      };

      // TODO: Mandar al backend
      print("Guardando: $payload");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reparación guardada exitosamente'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
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
              // FECHA DE ATENCIÓN
              const Text('Fecha de Atención *', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy hh:mm:ss a').format(_fechaAtencion)),
                ),
              ),
              const SizedBox(height: 20),

              // FALLA REPORTADA (Heredada, solo lectura)
              const Text('Falla Reportada', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
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

              // DIAGNÓSTICO (Cascada Padre)
              const Text('Diagnóstico *', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _diagnosticoSeleccionado,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: Text(_cargandoCatalogos ? 'Cargando...' : 'Seleccione...'),
                items: _listaDiagnosticos.map((String diag) {
                  return DropdownMenuItem(value: diag, child: Text(diag));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _diagnosticoSeleccionado = newValue);
                  if (newValue != null) _cargarReparaciones(newValue);
                },
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // REPARACIÓN (Cascada Hijo)
              const Text('Reparación *', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _reparacionSeleccionada,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: Text(_diagnosticoSeleccionado == null 
                  ? 'Seleccione un diagnóstico primero' 
                  : 'Seleccione...'),
                items: _listaReparaciones.map((String rep) {
                  return DropdownMenuItem(value: rep, child: Text(rep));
                }).toList(),
                onChanged: _diagnosticoSeleccionado == null ? null : (String? newValue) {
                  setState(() => _reparacionSeleccionada = newValue);
                },
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // COMENTARIOS
              const Text('Comentarios', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _comentariosController,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // SECCIÓN DE EVIDENCIAS (Botones estilo cámara/pdf)
              const Text('Evidencia 1', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildBotonEvidencia(Icons.camera_alt, 'Tomar Foto'),
              
              const SizedBox(height: 20),
              
              const Text('Video Evidencia', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildBotonEvidencia(Icons.picture_as_pdf, 'Subir Archivo'),
              
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
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _guardarReparacion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2396B9),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para los botones de evidencia grandes
  Widget _buildBotonEvidencia(IconData icono, String label) {
    return InkWell(
      onTap: () {
        // Lógica del ImagePicker
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(icono, size: 32, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}