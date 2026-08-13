import 'package:bea_service_app/core/widgets/fila_dato_text.dart';
import 'package:bea_service_app/features/refacciones/presentation/form_solicitud_refaccion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:bea_service_app/features/tickets/data/models/reparacion_model.dart';

class ReparacionDetalleScreen extends StatelessWidget {
  final dynamic reparacion; // Cambia 'dynamic' por 'ReparacionModel' cuando importes tu modelo

  const ReparacionDetalleScreen({super.key, required this.reparacion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Reparación'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEncabezado(),
            const SizedBox(height: 16),
            _buildInformacionGeneral(),
            const SizedBox(height: 16),
            _buildComentarios(),
            const SizedBox(height: 24),
            _buildGaleriaEvidencias(context),
            const SizedBox(height: 40),

            //_buildAcordeonRefacciones(reparacion.refacciones ?? []), // Asegúrate de que 'refacciones' sea una lista de mapas
            const SizedBox(height: 24),




          ],
        ),
      ),
            bottomNavigationBar: _buildBarraDeAcciones(context), 

    );
  }

  Widget _buildEncabezado() {
    return Card(
      elevation: 0,
      color: const Color(0xFF2396B9).withOpacity(0.1), // Un azul muy suave
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2396B9), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.build_circle, size: 40, color: Color(0xFF2396B9)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reparacion.diagnostico ?? 'Sin diagnóstico',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2396B9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reparacion.reparacion ?? 'Sin acción descrita',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionGeneral() {
    final nombreAparato = reparacion.dispositivo?.nombre ?? reparacion.dispositivo?.descripcion ?? 'No especificado';
    final fechaStr = reparacion.fechaResolucion != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(reparacion.fechaResolucion!)
        : 'Fecha desconocida';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            FilaDato(etiqueta: 'Dispositivo:', valor: nombreAparato),
            const SizedBox(height: 8),
            FilaDato(etiqueta: 'Fecha de atención:', valor: fechaStr),
          ],
        ),
      ),
    );
  }

  Widget _buildComentarios() {
    final comentarios = reparacion.comentarios;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.comment, size: 20, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text('Comentarios del Técnico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              (comentarios != null && comentarios.trim().isNotEmpty) 
                  ? comentarios 
                  : 'El técnico no dejó comentarios adicionales.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaleriaEvidencias(BuildContext context) {
    // Manejo seguro del arreglo de evidencias
    final List<String> evidencias = reparacion.evidencias ?? [];

    if (evidencias.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Evidencias Adjuntas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No hay fotos ni videos', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evidencias Adjuntas (${evidencias.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true, // Vital para usar GridView dentro de un SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columnas
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1, // Cuadrados perfectos
          ),
          itemCount: evidencias.length,
          itemBuilder: (context, index) {
            final url = evidencias[index];
            final esVideoUrl = _esVideo(url);

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Si es foto, mostramos la imagen. Si es video, un fondo negro
                  !esVideoUrl
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.black87,
                          child: const Icon(Icons.videocam, size: 48, color: Colors.white54),
                        ),
                        
                  // Opcional: Un efecto al presionar (Material Ripple)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Aquí podrías abrir un visor de imágenes en pantalla completa
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(esVideoUrl ? 'Abrir video...' : 'Abrir imagen...')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }


  // Widget _buildAcordeonRefacciones(List<Map<String, dynamic>> refacciones) {
  //   return Card(
  //     elevation: 0,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       side: BorderSide(color: Colors.grey.shade300),
  //     ),
  //     child: ExpansionTile(
  //       shape: const Border(),
  //       leading: const Icon(Icons.memory, color: Colors.teal),
  //       title: Row(
  //         children: [
  //           const Text('Refacciones Solicitadas', style: TextStyle(fontWeight: FontWeight.bold)),
  //           const SizedBox(width: 8),
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //             decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
  //             child: Text('${refacciones.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
  //           )
  //         ],
  //       ),
  //       children: refacciones.map((ref) {
  //         final isEntregado = ref['estado'].toString().toLowerCase() == 'entregado';
          
  //         return Column(
  //           children: [
  //             const Divider(height: 1),
  //             ListTile(
  //               title: Text(ref['refaccion'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
  //               subtitle: Text('Cantidad: ${ref['cantidad']}'),
  //               trailing: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: isEntregado ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: isEntregado ? Colors.green : Colors.orange),
  //                 ),
  //                 child: Text(
  //                   ref['estado'],
  //                   style: TextStyle(
  //                     fontSize: 10,
  //                     fontWeight: FontWeight.bold,
  //                     color: isEntregado ? Colors.green.shade700 : Colors.orange.shade700,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }


Widget _buildBarraDeAcciones(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        // Usamos una columna en modo "min" para que solo ocupe el espacio necesario
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            // Botón 2: Solicitar Refacción (Outlined, Acción secundaria)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navegar a pantalla de solicitar refacción
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SolicitarRefaccionScreen(ticket: reparacion.idTicket),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Solicitar Refacción'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: const Color(0xFF2396B9),
                  side: const BorderSide(color: Color(0xFF2396B9), width: 1.5), // Borde azul
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Utilidad para saber si pintar una foto o el ícono de video basándonos en el URL
  bool _esVideo(String url) {
    final ext = url.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }
}
