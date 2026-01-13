import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Callback para quando um deep link é recebido
  Function(Uri)? _onLinkReceived;

  /// Inicializar o serviço de deep links
  Future<void> initialize({Function(Uri)? onLinkReceived}) async {
    _appLinks = AppLinks();
    _onLinkReceived = onLinkReceived;

    // Verificar se o app foi aberto por um deep link
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Escutar por novos deep links quando o app já está rodando
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        debugPrint('Erro no deep link: $err');
      },
    );
  }

  /// Processar deep link recebido
  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link recebido: $uri');

    // Chamar callback personalizado se definido
    _onLinkReceived?.call(uri);

    // Lógica de roteamento baseada no URI
    _routeFromUri(uri);
  }

  /// Roteamento baseado no URI
  void _routeFromUri(Uri uri) {
    final path = uri.path;
    final queryParams = uri.queryParameters;

    switch (path) {
      case '/pet':
        final petId = queryParams['id'];
        if (petId != null) {
          _navigateToPet(petId);
        }
        break;

      case '/profile':
        final userId = queryParams['user'];
        if (userId != null) {
          _navigateToProfile(userId);
        }
        break;

      case '/adoption':
        _navigateToAdoption();
        break;

      default:
        _navigateToHome();
    }
  }

  /// Exemplos de navegação
  void _navigateToPet(String petId) {
    // Implementar navegação para tela do pet
    debugPrint('Navegando para pet: $petId');
    // Navigator.pushNamed(context, '/pet', arguments: petId);
  }

  void _navigateToProfile(String userId) {
    // Implementar navegação para perfil
    debugPrint('Navegando para perfil: $userId');
    // Navigator.pushNamed(context, '/profile', arguments: userId);
  }

  void _navigateToAdoption() {
    // Implementar navegação para adoção
    debugPrint('Navegando para adoção');
    // Navigator.pushNamed(context, '/adoption');
  }

  void _navigateToHome() {
    // Implementar navegação para home
    debugPrint('Navegando para home');
    // Navigator.pushReplacementNamed(context, '/');
  }

  /// Limpar recursos
  void dispose() {
    _linkSubscription?.cancel();
  }
}
