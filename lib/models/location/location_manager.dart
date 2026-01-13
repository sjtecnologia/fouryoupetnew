// ignore_for_file: deprecated_member_use, invalid_return_type_for_catch_error

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../services/permissions_service.dart';

/// Enumeração que representa o status da permissão de localização.
enum LocationStatus {
  unknown, // Estado inicial, desconhecido
  requesting, // Solicitação de permissão em andamento
  allowed, // Permissão concedida e localização disponível
  denied, // Permissão negada pelo usuário (pode ser solicitada novamente)
  deniedForever, // Permissão negada permanentemente (precisa ir para configurações do app)
  serviceDisabled, // Serviço de localização (GPS) desativado no dispositivo
  error, // Ocorreu um erro ao tentar obter a localização/permissão
}

/// Gerencia o status da localização e a posição atual do usuário.
/// Utiliza `PermissionsService` para evitar chamadas duplicadas de permissão.
class LocationManager extends ChangeNotifier {
  LocationStatus _status = LocationStatus.unknown;
  Position? _position;
  String? _error;

  LocationStatus get status => _status;
  Position? get position => _position;
  String? get error => _error;

  bool _initializing = false; // Flag para controlar se já está inicializando

  /// Inicializa o processo de verificação e solicitação de localização.
  /// Garante que `init` não seja chamado múltiplas vezes em paralelo.
  Future<void> init() async {
    if (_initializing) return; // Já está inicializando, sai.
    _initializing = true;
    _status = LocationStatus.requesting; // Define status como "solicitando"
    notifyListeners(); // Notifica listeners sobre a mudança de status

    try {
      // Verifica se o serviço de localização está habilitado no dispositivo.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _status = LocationStatus.serviceDisabled; // Serviço desativado
        notifyListeners();
        _initializing = false;
        return;
      }

      // Usa o serviço central `PermissionsService` para garantir que a permissão
      // seja solicitada de forma deduplicada e segura.
      final perm = await PermissionsService().ensureLocationPermissionOnce();

      // Avalia o resultado da permissão.
      if (perm == LocationPermission.denied) {
        _status = LocationStatus.denied; // Permissão negada
        notifyListeners();
        _initializing = false;
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        _status =
            LocationStatus.deniedForever; // Permissão negada permanentemente
        notifyListeners();
        _initializing = false;
        return;
      }

      _status = LocationStatus.allowed; // Permissão concedida

      // Tenta obter a última posição conhecida (geralmente mais rápida).
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _position = last;
        notifyListeners();
      }

      // Obtém a posição atual com um `timeLimit` para evitar travamentos.
      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      _position = current; // Atualiza a posição
      notifyListeners();
    } catch (e) {
      // Captura qualquer erro no processo.
      _error = e.toString();
      _status = LocationStatus.error; // Define status como erro
      notifyListeners();
    } finally {
      // Garante que a flag de inicialização seja resetada no final.
      _initializing = false;
    }
  }

  /// Tenta reiniciar o processo de obtenção de localização/permissão.
  Future<void> retry() async {
    _error = null; // Limpa erro anterior
    await init(); // Tenta inicializar novamente
  }

  /// Abre as configurações do aplicativo no sistema para que o usuário
  /// possa ajustar as permissões.
  Future<void> openSettings() async {
    await ph.openAppSettings();
  }
}
