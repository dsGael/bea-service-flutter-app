import 'package:bea_service_app/features/refacciones/presentation/providers/refacciones_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bea_service_app/features/tickets/data/models/ticket_model.dart';
import 'package:bea_service_app/features/tickets/presentation/providers/tickets_provider.dart';

class SolicitarRefaccionScreen extends ConsumerStatefulWidget {
  final TicketModel ticket;
  const SolicitarRefaccionScreen({super.key, required this.ticket});

  @override
  ConsumerState<SolicitarRefaccionScreen> createState() => _SolicitarRefaccionScreenState();
}

class _SolicitarRefaccionScreenState extends ConsumerState<SolicitarRefaccionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController(text: '1'); // Default 1 pieza
  
  bool _guardando = false;
  String? _dispositivoSeleccionado;

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _guardarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      // 1. Guardamos la solicitud de refacción
      await ref.read(refaccionesControllerProvider).solicitarRefaccion(
        idTicket: widget.ticket.idticket,
        idDispositivo: _dispositivoSeleccionado!,
        cantidad: double.parse(_cantidadController.text.trim()),
      );


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Refacción solicitada. Folio en pausa.'),
            backgroundColor: Color.fromARGB(255, 66, 151, 69),
          ),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        String mensajeError = 'Error al guardar';
        
        if (e is DioException && e.response != null) {
          final data = e.response!.data;
          print('🚨 RECHAZO DEL BACKEND: $data');
          
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
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dispositivosAsync = ref.watch(dispositivosPorTipoProvider('Equipo'));

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Refacción')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Folio actual'),
              TextFormField(
                initialValue: widget.ticket.folio ?? widget.ticket.idticket,
                readOnly: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown dinámico consumiendo el FutureProvider
              _label('Refacción *'),
              dispositivosAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => InputDecorator(
                  decoration: const InputDecoration(border: OutlineInputBorder(), errorText: 'Error al cargar catálogo'),
                  child: Text(err.toString()),
                ),
                data: (listaDispositivos) {
                  return DropdownButtonFormField<String>(
                    initialValue: _dispositivoSeleccionado,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: const Text('Seleccione...'),
                    isExpanded: true,
                   items: listaDispositivos.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.idDispositivoT.toString(),                           
                          child: Text(item.nombre ?? item.descripcion ?? 'Sin nombre'), 
                        );
                      }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _dispositivoSeleccionado = val;
                      });
                    },
                    validator: (value) => value == null ? 'Por favor selecciona una pieza' : null,
                  );
                },
              ),
              const SizedBox(height: 20),

              _label('Cantidad *'),
              TextFormField(
                controller: _cantidadController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixText: 'pzas',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Ingresa un número válido';
                  if (double.parse(value) <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
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
                  onPressed: _guardando ? null : _guardarSolicitud,
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
                      : const Text('Solicitar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}