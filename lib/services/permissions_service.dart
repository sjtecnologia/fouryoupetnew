import 'package:geolocator/geolocator.dart';

class PermissionsService {
  PermissionsService._internal();
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;

  Future<LocationPermission>? _inFlightLocationRequest;

  /// Garante que uma requisição de permissão de localização seja feita apenas uma vez por vez.
  /// Se `requestIfNeeded` for `true` e a permissão estiver negada, o popup de solicitação será mostrado.
  Future<LocationPermission> ensureLocationPermissionOnce(
      {bool requestIfNeeded = true}) {
    // Se já existe uma requisição em andamento, retorna a Future existente para evitar duplicidade.
    if (_inFlightLocationRequest != null) return _inFlightLocationRequest!;

    // Inicia uma nova requisição e armazena a Future.
    _inFlightLocationRequest =
        _ensureLocationPermission(requestIfNeeded: requestIfNeeded)
            .whenComplete(() {
      // Quando a requisição terminar (com sucesso ou falha), limpa a referência.
      _inFlightLocationRequest = null;
    });
    return _inFlightLocationRequest!;
  }

  /// Lógica interna para checar e solicitar permissão.
  Future<LocationPermission> _ensureLocationPermission(
      {required bool requestIfNeeded}) async {
    // Primeiro, verifica se o serviço de localização está ativo no dispositivo.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Se o serviço estiver desativado, retorna 'denied' (como se o usuário tivesse negado,
      // mas na verdade é a configuração do sistema). Não tenta solicitar permissão aqui.
      return LocationPermission.denied;
    }

    // Checa o status atual da permissão do aplicativo.
    var permission = await Geolocator.checkPermission();

    // Se a permissão estiver negada e a flag `requestIfNeeded` for `true`, solicita a permissão ao usuário.
    if (requestIfNeeded && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // Retorna o status final da permissão.
    return permission;
  }
}
