import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/tickets_provider.dart';

class TicketsListScreen extends ConsumerWidget {
  const TicketsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsListMantenimientoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis folios')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ticketsListMantenimientoProvider.future),
        child: ticketsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error al cargar: $err')),
          data: (tickets) {
            if (tickets.isEmpty) {
              return const Center(child: Text('No tienes folios abiertos'));
            }
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return ListTile(
                  title: Text(ticket.folio ?? 'Sin folio'),
                  subtitle: Text(ticket.nombreFalla ?? ticket.comentarios ?? ''),
                  trailing: Chip(label: Text(ticket.nombreEstado ?? '—')),
                  onTap: () {
                    // siguiente paso: navegar al detalle
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}