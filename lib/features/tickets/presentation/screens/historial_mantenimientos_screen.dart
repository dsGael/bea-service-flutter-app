import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:bea_service_app/core/widgets/ticket_card.dart';
// 👇 CAMBIO 1: Importamos tu nuevo buscador
import 'package:bea_service_app/core/widgets/debounced_search_bar.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tickets_provider.dart';

class HistorialMantenimientosScreen extends ConsumerStatefulWidget {
  const HistorialMantenimientosScreen({super.key});

  @override
  ConsumerState<HistorialMantenimientosScreen> createState() => _HistorialMantenimientosScreenState();
}

class _HistorialMantenimientosScreenState extends ConsumerState<HistorialMantenimientosScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // 👇 CAMBIO 2: Creamos la variable que guardará lo que el usuario escriba
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
      // Como movimos el filtro al build, aquí reconstruimos el filtro actual para saber qué pedir en la sig. página
      final filtroActual = (
        isMantenimiento: true,
        isAbierto: null,
        idtecnico: null,
        buscar: _terminoBusqueda.isEmpty ? null : _terminoBusqueda,
      );
      ref.read(ticketsPaginadosProvider(filtroActual).notifier).cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 CAMBIO 3: Movimos el filtro adentro del build y le agregamos el parámetro 'buscar'
    // Ahora, cada vez que '_terminoBusqueda' cambie, este filtro se actualiza.
    final filtro = (
      isMantenimiento: true,
      isAbierto: null,
      idtecnico: null,
      buscar: _terminoBusqueda.isEmpty ? null : _terminoBusqueda,
    );

    final ticketsMantenimiento = ref.watch(ticketsPaginadosProvider(filtro));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Mantenimientos'),
        
        // 👇 CAMBIO 4: Agregamos la barra de búsqueda en la parte inferior del AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DebouncedSearchBar(
              placeholder: 'Buscar folio, unidad...',
              onSearchChanged: (texto) {
                // Cuando el debouncer nos avise que el usuario dejó de teclear,
                // actualizamos la variable y obligamos a la pantalla a redibujarse (setState).
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
            
            if (ticketsMantenimiento.cargandoInicial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ticketsMantenimiento.tickets.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(child: Text('No se encontraron mantenimientos.')),
                ],
              );
            }

            return ListView.builder(
              controller: _scrollController, 
              itemCount: ticketsMantenimiento.alcanzoElFinal 
                  ? ticketsMantenimiento.tickets.length 
                  : ticketsMantenimiento.tickets.length + 1,
              itemBuilder: (context, index) {
                if (index == ticketsMantenimiento.tickets.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()), 
                  );
                }

                final ticket = ticketsMantenimiento.tickets[index];
                
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