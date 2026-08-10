import 'package:bea_service_app/features/tickets/data/models/ticket_model.dart';
import 'package:bea_service_app/features/tickets/presentation/screens/form_crear_reparacion_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class TicketDetalleScreen extends StatelessWidget {
  final TicketModel ticket; 

  const TicketDetalleScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final folioMostrar = ticket.folio ?? ticket.idticket.substring(0, 6).toUpperCase();
    final listaReparaciones = [
      {"folio": "RPT5951-b", "fecha": "14/07/2026 05:04 AM"},
      {"folio": "RPT5951", "fecha": "16/07/2026 01:03 AM"},
      {"folio": "RPT5951", "fecha": "25/07/2026 02:03 PM"},
      ];

    final listaRefacciones = [
      {"estado": "Entregado", "refaccion": "ANTENA GPS", "cantidad": 1},
      {"estado": "Pendiente", "refaccion": "ENTRADA DE ENERGIA", "cantidad": 1},
      ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Folio: $folioMostrar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderEstado(),
            const SizedBox(height: 20),

            _buildInformacionUnidad(context),
            const SizedBox(height: 16),

            _buildDetalleFalla(),
            const SizedBox(height: 16),

            _buildEvidenciaFotografica(),
            const SizedBox(height: 16),

            _buildAcordeonReparaciones(listaReparaciones),
            const SizedBox(height: 12),

            _buildAcordeonRefacciones(listaRefacciones),
            const SizedBox(height: 24), 
          ],
        ),
      ),

      bottomNavigationBar: _buildBarraDeAcciones(context), 
    );
  }

  Widget _buildHeaderEstado() {
    // Leemos el estado desde el catálogo
    final estadoStr = ticket.estado?.nombre ?? 'N/A';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Chip(
          label: Text(
            estadoStr.toUpperCase(), 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
          ),
          backgroundColor: _getColorPorEstado(estadoStr),
          side: BorderSide.none,
        ),
        Text(
          ticket.fechacreacion != null 
              ? DateFormat('dd MMM yyyy, HH:mm').format(ticket.fechacreacion!) 
              : 'Fecha desconocida',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildInformacionUnidad(BuildContext context) {
    // Priorizamos el número económico del catálogo de autobuses
    final unidad = ticket.autobus?.numeroEconomico ?? ticket.numeroeconomico ?? 'Sin asignar';
    final operador = ticket.nombreoperador ?? 'No registrado';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.directions_bus, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unidad: $unidad - Ruta: ', 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, )
                  ),
                  Text(
                    'Operador: $operador', 
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleFalla() {
    // Extraemos los nombres desde los catálogos
    final nombreFalla = ticket.falla?.nombre ?? 'Falla general';
    final especificacionFalla = ticket.falla?.falla; 
    
    // Si viene el nombre y la especificación (ej. MOBILE DVR - Apagado), los unimos
    final fallaCompleta = especificacionFalla != null && especificacionFalla.isNotEmpty
        ? '$especificacionFalla'
        : nombreFalla;

    final dispositivo = ticket.dispositivo?.nombre ?? ticket.dispositivo?.descripcion ?? 'N/A';

    // final ruta= ticket.ruta?
    
    final prioridad = ticket.prioridad?.nombre ?? 'Normal';

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
            const Text('Detalle del Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            
            _FilaDato(etiqueta: 'Prioridad:', valor: prioridad),
            const SizedBox(height: 8),
              _FilaDato(etiqueta: 'Dispositivo:', valor: dispositivo),
            const SizedBox(height: 8),
            _FilaDato(etiqueta: 'Falla:', valor: fallaCompleta),
            const SizedBox(height: 12),
          
            
            const Text('Comentarios:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              ticket.comentarios != null && ticket.comentarios!.isNotEmpty 
                  ? ticket.comentarios! 
                  : 'Sin comentarios adicionales.',
              style: const TextStyle(height: 1.5, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenciaFotografica() {
    if (ticket.imagenfalla1 == null || ticket.imagenfalla1!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Evidencia Adjunta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ticket.imagenfalla1!.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(ticket.imagenfalla1![index]), 
                    fit: BoxFit.cover
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAcordeonReparaciones(List<Map<String, dynamic>> reparaciones) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        shape: const Border(), // Quita las líneas feas por defecto de Flutter al expandir
        leading: const Icon(Icons.history, color: Colors.blueGrey),
        title: Row(
          children: [
            const Text('Reparaciones Realizadas', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            // Burbuja gris con el contador
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Text('${reparaciones.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        children: reparaciones.map((rep) {
          return Column(
            children: [
              const Divider(height: 1),
              ListTile(
                title: Text(rep['folio'], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Fecha de reparación: ${rep['fecha']}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 24, color: Color.fromARGB(255, 133, 132, 132)),
                onTap: () {
                  // Opcional: Navegar al detalle de esa reparación específica
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }


  Widget _buildAcordeonRefacciones(List<Map<String, dynamic>> refacciones) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: const Icon(Icons.memory, color: Colors.teal),
        title: Row(
          children: [
            const Text('Refacciones Solicitadas', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Text('${refacciones.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        children: refacciones.map((ref) {
          final isEntregado = ref['estado'].toString().toLowerCase() == 'entregado';
          
          return Column(
            children: [
              const Divider(height: 1),
              ListTile(
                title: Text(ref['refaccion'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Cantidad: ${ref['cantidad']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEntregado ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isEntregado ? Colors.green : Colors.orange),
                  ),
                  child: Text(
                    ref['estado'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isEntregado ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }


  Widget _buildBarraDeAcciones(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        // Usamos una columna en modo "min" para que solo ocupe el espacio necesario
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            // Botón 1: Agregar Reparación (Sólido, Acción principal)
            SizedBox(
              width: double.infinity, // Hace que el botón abarque todo el ancho
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navegar a pantalla de crear reparación, pasando el ticket
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReparacionFormScreen(ticket: ticket),
                    ),
                  );
                },
                icon: const Icon(Icons.build),
                label: const Text('Agregar Reparación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2396B9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12), // Espaciador entre botones
            
            // Botón 2: Solicitar Refacción (Outlined, Acción secundaria)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navegar a pantalla de solicitar refacción
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


  Color _getColorPorEstado(String? estado) {
    if (estado == null) return Colors.grey;
    final edo = estado.toLowerCase();
    if (edo.contains('pendiente') || edo.contains('abierto')) return Colors.orange.shade700;
    if (edo.contains('progreso')) return Colors.blue.shade700;
    if (edo.contains('resuelto') || edo.contains('cerrado')) return Colors.green.shade700;
    return Colors.grey;
  }
}

class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  
  const _FilaDato({required this.etiqueta, required this.valor});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: const TextStyle(color: Color.fromARGB(255, 37, 37, 37), fontWeight: FontWeight.w500, fontSize: 18, ),),
          const SizedBox(width: 8),
          Expanded(child: Text(valor, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),)),
        ],
      ),
    );
  }
}