import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tickets_provider.dart';
// Asegúrate de tener importado tu TicketModel si es necesario

class HistorialTicketsScreen extends ConsumerWidget {
  const HistorialTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ticketsFiltroProvider((
    isMantenimiento: null,
    isAbierto: null,
    idtecnico: null,
    )); 
    
    final ticketsMantenimiento = ref.watch(filtro);
    debugPrint('ticketsMantenimiento: $ticketsMantenimiento');

  

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Tickets')),
      drawer: const AppDrawer(), 
      
      // AQUI NO SE USA PERO QUIERO TENERLO POR SI LO OCUPO FLOTANDO POR AHI
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Esto empuja la nueva pantalla de formulario sobre la actual
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const ReparacionFormScreen(ticket: ticket),
      //       ),
      //     );
      //   },
      //   backgroundColor: const Color(0xFF2396B9), 
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //   elevation: 4,
      //   // Sugerencia: Icons.add tiene más sentido visual para un botón de "Crear"
      //   child: const Icon(Icons.add, color: Colors.white, size: 28),
      // ),
      
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(filtro.future),
        child: ticketsMantenimiento.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error al cargar: $err')),
          data: (tickets) {
            if (tickets.isEmpty) {
              return const Center(child: Text('No hay folios de mantenimiento.'));
            }
            
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                
                // 1. Extraemos valores seguros usando nuestros sub-modelos (Catálogos)
                final folio = ticket.folio ?? ticket.idticket.substring(0, 6).toUpperCase();
                final estadoStr = ticket.estado?.nombre ?? 'PENDIENTE';
                final fallaStr = ticket.falla?.nombre ?? ticket.comentarios ?? 'Sin descripción';
                final unidadStr = ticket.autobus?.numeroEconomico ?? ticket.numeroeconomico ?? 'Sin Unidad';
                
                // 2. Formateamos la fecha (Ej: 21/07/2026)
                final fechaFormateada = ticket.fechacreacion != null 
                    ? "${ticket.fechacreacion!.day.toString().padLeft(2, '0')}/${ticket.fechacreacion!.month.toString().padLeft(2, '0')}/${ticket.fechacreacion!.year}"
                    : 'Sin fecha';

               return Card(
                  elevation: 2,
                  color: const Color.fromARGB(255, 243, 243, 241), // background color
                  clipBehavior: Clip.antiAlias, //recortado para el redondeo
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    // tileColor: ... (LO QUITAMOS DE AQUÍ)
                    
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: const Icon(Icons.handyman, color: Colors.teal),
                    ),
                    
                    title: Text(
                      folio,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    
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
                    
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                                fontSize: 16, // Tu fecha grande
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
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

  // Función de ayuda para colorear el badge de estado
  Color _getColorPorEstado(String estado) {
    final edo = estado.toLowerCase();
    if (edo.contains('abierto') || edo.contains('pendiente')) return Colors.orange.shade700;
    if (edo.contains('progreso')) return Colors.blue.shade700;
    if (edo.contains('cerrado') || edo.contains('resuelto')) return Colors.green.shade700;
    return Colors.grey.shade700;
  }
}