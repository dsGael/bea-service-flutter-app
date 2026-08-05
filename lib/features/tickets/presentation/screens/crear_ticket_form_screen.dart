import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tickets_provider.dart';

// Usamos ConsumerStatefulWidget porque necesitamos manejar controladores de texto (State) 
// y enviar datos usando Riverpod (Consumer)
class CrearTicketFormScreen extends ConsumerStatefulWidget {
  const CrearTicketFormScreen({super.key});

  @override
  ConsumerState<CrearTicketFormScreen> createState() => _CrearTicketFormScreenState();
}

class _CrearTicketFormScreenState extends ConsumerState<CrearTicketFormScreen> {
  // 1. LA LLAVE MAESTRA: Controla todo el formulario
  final _formKey = GlobalKey<FormState>();

  // 2. CONTROLADORES: Guardan lo que el usuario escribe
  final _comentariosController = TextEditingController();
  
  // (Opcional) Un estado local para saber si está cargando y bloquear el botón
  bool _isLoading = false;

  // 3. LIMPIEZA: Siempre debes destruir los controladores al cerrar la pantalla
  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  // 4. LA ACCIÓN: Qué pasa al presionar "Guardar"
  Future<void> _submitForm() async {
    // Valida que todos los campos cumplan sus reglas (que no estén vacíos, etc.)
    if (!_formKey.currentState!.validate()) {
      return; // Si hay error, se detiene aquí y muestra los textos rojos en pantalla
    }

    setState(() => _isLoading = true);

    try {
      // Armamos el JSON que espera NestJS
      final ticketData = {
        'comentarios': _comentariosController.text,
        'idautobus': '123', // Ejemplo fijo por ahora
      };

      // Llamamos a tu controlador de Riverpod que hicimos en el paso anterior
      await ref.read(ticketsControllerProvider).crearMantenimiento(ticketData);

      // Refrescamos la lista de la pantalla anterior para que aparezca el nuevo ticket
      ref.invalidate(ticketsListMantenimientoAbiertosProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket creado con éxito'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Regresa a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Mantenimiento')),
      // 5. EL WIDGET FORM: Envuelve todo
      body: Form(
        key: _formKey, // Le pasamos la llave maestra
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Detalles del reporte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 6. EL INPUT: TextFormField tiene validación integrada
            TextFormField(
              controller: _comentariosController,
              maxLines: 3, // Lo hace ver como un Textarea
              decoration: InputDecoration(
                labelText: 'Comentarios o descripción',
                hintText: 'Describe la falla detalladamente...',
                border: OutlineInputBorder( // Le da un borde bonito tipo caja
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              // REGLA DE VALIDACIÓN
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un comentario'; // Mensaje de error automático
                }
                if (value.length < 10) {
                  return 'El comentario es muy corto';
                }
                return null; // Null significa que todo está perfecto
              },
            ),
            
            const SizedBox(height: 32),

            // 7. EL BOTÓN
            SizedBox(
              width: double.infinity, // Hace que el botón ocupe todo el ancho
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm, // Se desactiva si está cargando
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Ticket', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}