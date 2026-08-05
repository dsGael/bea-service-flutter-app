import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tickets_provider.dart';

class TicketsCorrectivosListScreen extends ConsumerWidget {
  const TicketsCorrectivosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketListCorrectivoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Correctivos Pendientes')),
      drawer: const AppDrawer(), 
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ticketListCorrectivoProvider.future),
        child: ticketsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error al cargar: $err')),
          data: (tickets) {
            if (tickets.isEmpty) {
              return const Center(child: Text('No hay folios Correctivos abiertos.'));
            }
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
               return Card(
  elevation: 3, // Qué tan pronunciada es la sombra
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Separación entre tarjetas
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: ListTile(
    contentPadding: const EdgeInsets.all(16), // Espacio adentro de la tarjeta
    
    // Icono a la izquierda (Opcional pero se ve muy bien)
    leading: CircleAvatar(
      backgroundColor: Colors.blue.shade100,
      child: const Icon(Icons.build, color: Colors.blue),
    ),
    
    title: Text(
      ticket.folio ?? 'Sin folio',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(ticket.nombreFalla ?? ticket.comentarios ?? ''),
    ),
    
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Chip(
          label: Text(
            ticket.nombreEstado?.toString() ?? '—',
            style: const TextStyle(fontSize: 12),
          ),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact, // Hace el chip más pequeño para que quepa bien
        ),// En lugar del Chip, pon esto en el 'trailing':
Row(
  mainAxisSize: MainAxisSize.min, // Importante para que no ocupe toda la fila
  children: [
    // const Icon(
    //   Icons.pending_actions, // Cambia según el estado
    //   size: 16, 
    //   color: Colors.orange,
    // ),
    const SizedBox(width: 4), // Separación
    Text(
      ticket.fechacreacion!.toLocal().toString().split(' ')[0], // Solo la fecha
      style: const TextStyle(
        color: Colors.orange,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
)
      ],
    ),
    
    onTap: () {
      // navegar al detalle
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
}