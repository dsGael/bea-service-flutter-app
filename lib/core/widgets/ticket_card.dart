import 'package:flutter/material.dart';
// Asegúrate de que esta ruta apunte a tu modelo real:
import 'package:bea_service_app/features/tickets/data/models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key, 
    required this.ticket, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Extraemos valores seguros
    final folio = ticket.folio ?? ticket.idticket.substring(0, 6).toUpperCase();
    final estadoStr = ticket.estado?.nombre ?? 'PENDIENTE';
    final fallaStr = ticket.falla?.nombre ?? ticket.comentarios ?? 'Sin descripción';
    final unidadStr = ticket.autobus?.numeroEconomico ?? ticket.numeroeconomico ?? 'Sin Unidad';
    
    // 2. Formateamos la fecha
    final fechaFormateada = ticket.fechacreacion != null 
        ? "${ticket.fechacreacion!.day.toString().padLeft(2, '0')}/${ticket.fechacreacion!.month.toString().padLeft(2, '0')}/${ticket.fechacreacion!.year}"
        : 'Sin fecha';

    // 3. Retornamos tu diseño de tarjeta
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 243, 243, 241),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
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
                    fontSize: 16, 
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
        onTap: onTap, // 👈 Aquí pasamos la función que recibe el widget
      ),
    );
  }

  // Mudamos la función de ayuda aquí adentro para que la tarjeta sea 100% independiente
  Color _getColorPorEstado(String estado) {
    final edo = estado.toLowerCase();
    if (edo.contains('abierto') || edo.contains('pendiente')) return Colors.orange.shade700;
    if (edo.contains('progreso')) return Colors.blue.shade700;
    if (edo.contains('cerrado') || edo.contains('resuelto')) return Colors.green.shade700;
    return Colors.grey.shade700;
  }
}