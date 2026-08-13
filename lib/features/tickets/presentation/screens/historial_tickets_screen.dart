import 'package:bea_service_app/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 👇 Asegúrate de importar tus nuevos widgets reutilizables
import 'package:bea_service_app/core/widgets/ticket_card.dart';
import 'package:bea_service_app/core/widgets/debounced_search_bar.dart'; 

import '../providers/tickets_provider.dart';

// 1. Cambiamos a ConsumerStatefulWidget para manejar el Scroll
class HistorialTicketsScreen extends ConsumerStatefulWidget {
  const HistorialTicketsScreen({super.key});

  @override
  ConsumerState<HistorialTicketsScreen> createState() => _HistorialTicketsScreenState();
}

class _HistorialTicketsScreenState extends ConsumerState<HistorialTicketsScreen> {
  // 2. Controladores de Scroll y Búsqueda
  final ScrollController _scrollController = ScrollController();
  String _terminoBusqueda = '';

  @override
  void initState() {
    super.initState();
    // Conectamos el oyente del scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Limpiamos la memoria al salir
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Usamos el mismo filtro que está en el build para pedir la siguiente página
      final filtro = (
        isMantenimiento: null, 
        isAbierto: null, 
        idtecnico: null,
        buscar: _terminoBusqueda.isEmpty ? null : _terminoBusqueda,
      );
      ref.read(ticketsPaginadosProvider(filtro).notifier).cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Declaramos el filtro (nota que agregamos la variable de búsqueda)
    final filtro = (
      isMantenimiento: null,
      isAbierto: null,
      idtecnico: null,
      buscar: _terminoBusqueda.isEmpty ? null : _terminoBusqueda,
    ); 
    
    // 4. Escuchamos nuestro nuevo Provider paginado
    final estadoTickets = ref.watch(ticketsPaginadosProvider(filtro));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tickets'),
        // 👇 ¡Agregamos tu nueva barra de búsqueda reutilizable!
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
          // Recargamos la primera página al jalar hacia abajo
          await ref.read(ticketsPaginadosProvider(filtro).notifier).cargarPrimeraPagina();
        },
        // 5. Reemplazamos el .when() por la lectura directa de nuestro TicketsState
        child: Builder(
          builder: (context) {
            
            // Estado: Cargando inicialmente
            if (estadoTickets.cargandoInicial) {
              return const Center(child: CircularProgressIndicator());
            }

            // Estado: Lista vacía
            if (estadoTickets.tickets.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(child: Text('No hay tickets registrados.')),
                ],
              );
            }

            // Estado: Con datos
            return ListView.builder(
              controller: _scrollController, // 👈 ¡Conectamos el scroll!
              itemCount: estadoTickets.alcanzoElFinal 
                  ? estadoTickets.tickets.length 
                  : estadoTickets.tickets.length + 1,
              itemBuilder: (context, index) {
                
                // Pintar el loader al fondo de la lista si está cargando más
                if (index == estadoTickets.tickets.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final ticket = estadoTickets.tickets[index];
                
                // 👇 ¡Toda tu lógica visual ahora vive en una sola línea gracias a tu Widget!
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