import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:bea_service_app/core/widgets/ticket_card.dart';
import 'package:bea_service_app/core/widgets/debounced_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tickets_provider.dart';

class TicketsMantenimientoListScreen extends ConsumerStatefulWidget {
  const TicketsMantenimientoListScreen({super.key});

  @override
  ConsumerState<TicketsMantenimientoListScreen> createState() => _TicketsMantenimientoListScreenState();
}

class _TicketsMantenimientoListScreenState extends ConsumerState<TicketsMantenimientoListScreen> {
  final ScrollController _scrollController = ScrollController();
  String _terminoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final filtro = (
        isMantenimiento: true,  // 👈 Mantenimientos son true
        isAbierto: true,        // 👈 Pendientes son true
        idtecnico: null,
        buscar: _terminoBusqueda.isEmpty ? null : _terminoBusqueda,
      );
      ref.read(ticketsPaginadosProvider(filtro).notifier).cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtro = (
      isMantenimiento: true,
      isAbierto: true,
      idtecnico: null,
      buscar: _terminoBusqueda.isEmpty ? null : _terminoBusqueda,
    );
    
    final estadoTickets = ref.watch(ticketsPaginadosProvider(filtro));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos Pendientes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DebouncedSearchBar(
              placeholder: 'Buscar folio, unidad o falla...',
              onSearchChanged: (texto) {
                setState(() {
                  _terminoBusqueda = texto;
                });
              },
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(), 
      
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(ticketsPaginadosProvider(filtro).notifier).cargarPrimeraPagina();
        },
        child: Builder(
          builder: (context) {
            
            if (estadoTickets.cargandoInicial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (estadoTickets.tickets.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(child: Text('No hay folios abiertos de mantenimiento.')),
                ],
              );
            }

            return ListView.builder(
              controller: _scrollController, 
              itemCount: estadoTickets.alcanzoElFinal 
                  ? estadoTickets.tickets.length 
                  : estadoTickets.tickets.length + 1,
              itemBuilder: (context, index) {
                
                if (index == estadoTickets.tickets.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final ticket = estadoTickets.tickets[index];
                
                return TicketCard(
                  ticket: ticket,
                  onTap: () {
                    context.push('/detalle-ticket', extra: ticket);
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