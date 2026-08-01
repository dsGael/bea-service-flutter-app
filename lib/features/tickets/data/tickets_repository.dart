import '../../../core/api/api_client.dart';
import 'models/ticket_model.dart';

class TicketsRepository {
  final ApiClient _apiClient;
  TicketsRepository(this._apiClient);

  Future<List<TicketModel>> listarPorTecnico(String idUsuarioApp) async {
    final response = await _apiClient.dio.get('/tickets/tecnico/$idUsuarioApp');
        final data = _apiClient.unwrap(response) as List;
    return data.map((json) => TicketModel.fromJson(json)).toList();
  }

  Future<TicketModel> obtenerPorId(String idticket) async {
    final response = await _apiClient.dio.get('/tickets/$idticket');
    return TicketModel.fromJson(response.data);
  }

  Future<void> actualizarTicket(String idticket, Map<String, dynamic> updates) async {
    await _apiClient.dio.put('/tickets/$idticket', data: updates);
  }

  Future<void> crearTicket(Map<String, dynamic> ticketData) async {
    await _apiClient.dio.post('/tickets', data: ticketData);
  }

  Future<List<TicketModel>> listarTodos() async {
    final response = await _apiClient.dio.get('/tickets');
        final data = _apiClient.unwrap(response) as List;
    return data.map((json) => TicketModel.fromJson(json)).toList();
  }


  Future<List<TicketModel>> listarMantenimiento() async{
    final response = await _apiClient.dio.get('/tickets/mantenimiento');
        final data = _apiClient.unwrap(response) as List;
    return data.map((json) => TicketModel.fromJson(json)).toList();
  }


}