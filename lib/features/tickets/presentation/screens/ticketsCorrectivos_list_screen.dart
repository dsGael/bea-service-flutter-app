import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tickets_provider.dart';
// Asegúrate de tener la importación de tu TicketModel aquí

class TicketsCorrectivosListScreen extends ConsumerWidget {
  const TicketsCorrectivosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final filtro = ticketsFiltroProvider((
    isMantenimiento: false,
    isAbierto: true,
    idtecnico: null,
    
  ) as TicketFilterArgs);

    final ticketsAbiertosCorrectivos = ref.watch(filtro);

    return Scaffold(
      appBar: AppBar(title: const Text('Correctivos Pendientes')),
      drawer: const AppDrawer(), 
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(filtro.future),
        child: ticketsAbiertosCorrectivos.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error al cargar: $err')),
          data: (tickets) {
            if (tickets.isEmpty) {
              return const Center(child: Text('No hay folios correctivos abiertos.'));
            }
            
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                
                // Extraemos valores seguros usando nuestros sub-modelos (Catálogos)
                final folio = ticket.folio ?? ticket.idticket.substring(0, 6).toUpperCase();
                final estadoStr = ticket.estado?.nombre ?? 'PENDIENTE';
                final fallaStr = ticket.falla?.nombre ?? ticket.comentarios ?? 'Sin descripción';
                final unidadStr = ticket.autobus?.numeroEconomico ?? ticket.numeroeconomico ?? 'Sin Unidad';
                
                // Formateamos la fecha (Ej: 21/07/2026)
                final fechaFormateada = ticket.fechacreacion != null 
                    ? "${ticket.fechacreacion!.day.toString().padLeft(2, '0')}/${ticket.fechacreacion!.month.toString().padLeft(2, '0')}/${ticket.fechacreacion!.year}"
                    : 'Sin fecha';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    
                    // Icono de herramienta
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.build, color: Colors.blue),
                    ),
                    
                    // Título (Folio)
                    title: Text(
                      folio,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    
                    // Subtítulo (Unidad y Falla)
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unidad: $unidadStr',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.grey.shade800
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fallaStr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lado derecho (Fecha y Estado)
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Fecha
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              fechaFormateada,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // "Chip" de estado personalizado (Más compacto para que no de error de overflow)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getColorPorEstado(estadoStr).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getColorPorEstado(estadoStr)),
                          ),
                          child: Text(
                            estadoStr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getColorPorEstado(estadoStr),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    onTap: () {
                      // Navegar al detalle pasando el modelo completo
                      context.push('/detalle-ticket', extra: ticket);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Función de ayuda para colorear el badge de estado en la lista
  Color _getColorPorEstado(String estado) {
    final edo = estado.toLowerCase();
    if (edo.contains('abierto') || edo.contains('pendiente')) return Colors.orange.shade700;
    if (edo.contains('progreso')) return Colors.blue.shade700;
    if (edo.contains('cerrado') || edo.contains('resuelto')) return Colors.green.shade700;
    return Colors.grey.shade700;
  }
}