// lib/features/checador/presentation/providers/checador_provider.dart
import 'package:bea_service_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/checador_repository.dart';
import '../../data/checador_models.dart';

final checadorRepositoryProvider = Provider((ref) {
  return ChecadorRepository(ref.watch(apiClientProvider));

});

final checadorControllerProvider =
    AsyncNotifierProvider<ChecadorController, ChecadorModel?>(ChecadorController.new);

class ChecadorController extends AsyncNotifier<ChecadorModel?> {
  @override
  ChecadorModel? build() => null; // estado inicial: sin checada reciente

  Future<void> registrarChecada({
    required String idUsuarioApp,
    required String nombre,
    required double lat,
    required double lng,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(checadorRepositoryProvider);

    state = await AsyncValue.guard(() {
      return repository.registrarChecada(
        idUsuarioApp: idUsuarioApp,
        nombre: nombre,
        lat: lat,
        lng: lng,
      );
    });
  }
}