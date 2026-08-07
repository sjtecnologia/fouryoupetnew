import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço para gerenciar autenticação biométrica.
///
/// Modelo Zero Knowledge: a senha NUNCA é armazenada localmente.
///
/// Fluxo:
/// 1. Usuário faz login (email/senha ou rede social)
/// 2. Apenas e-mail, provider e userId são salvos para identificação
/// 3. A sessão do Firebase (refresh token) é mantida pelo SDK no Keychain/KeyStore
/// 4. Na próxima abertura, a biometria é a barreira de acesso ao app;
///    após verificação biométrica, usa-se a sessão Firebase já persistida.
class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Chaves para armazenamento seguro (sem senha — modelo Zero Knowledge)
  static const String _keyEmail = 'saved_email';
  static const String _keyAuthProvider = 'saved_auth_provider';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyUserId = 'saved_user_id';

  /// Salva as credenciais de identificação após login bem-sucedido.
  /// A senha NUNCA é armazenada — apenas dados não-secretos de identificação.
  Future<void> saveCredentials({
    required String email,
    required String authProvider, // 'email', 'google', 'apple', 'facebook'
    required String userId,
  }) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyAuthProvider, value: authProvider);
    await _secureStorage.write(key: _keyUserId, value: userId);
    await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
  }

  /// Verifica se há credenciais salvas para login com biometria
  Future<bool> hasStoredCredentials() async {
    final email = await _secureStorage.read(key: _keyEmail);
    final userId = await _secureStorage.read(key: _keyUserId);
    final biometricEnabled =
        await _secureStorage.read(key: _keyBiometricEnabled);
    return email != null && userId != null && biometricEnabled == 'true';
  }

  /// Obtém o email salvo (para exibir na tela de login)
  Future<String?> getSavedEmail() async {
    return await _secureStorage.read(key: _keyEmail);
  }

  /// Obtém o provider de autenticação salvo
  Future<String?> getSavedAuthProvider() async {
    return await _secureStorage.read(key: _keyAuthProvider);
  }

  /// Verifica se o dispositivo suporta biometria
  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      return false;
    }
  }

  /// Obtém os tipos de biometria disponíveis
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Erro ao obter biometrias disponíveis: $e');
      return [];
    }
  }

  /// Detecta o melhor tipo de biometria disponível no dispositivo.
  /// Prioridade: rosto > impressão digital > íris > strong genérico.
  /// Retorna null se nenhuma biometria estiver disponível ou configurada.
  Future<BiometricType?> getBestAvailableBiometric() async {
    try {
      final canUse = await canUseBiometrics();
      if (!canUse) return null;

      final available = await getAvailableBiometrics();
      if (available.isEmpty) return null;

      // Aceita reconhecimento facial
      if (available.contains(BiometricType.face)) {
        return BiometricType.face;
      }
      // Prefere impressão digital quando Face ID não estiver disponível
      if (available.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
      // Aceita íris
      if (available.contains(BiometricType.iris)) {
        return BiometricType.iris;
      }
      // Biometria forte genérica (Android)
      if (available.contains(BiometricType.strong)) {
        return BiometricType.strong;
      }
      // Último recurso: qualquer tipo disponível
      return available.first;
    } catch (e) {
      return null;
    }
  }

  /// Autentica com biometria e retorna as credenciais se sucesso
  Future<Map<String, String>?> authenticateAndGetCredentials() async {
    try {
      // Primeiro verifica se há credenciais salvas
      final hasCredentials = await hasStoredCredentials();
      if (!hasCredentials) {
        return null;
      }

      // Tenta autenticar com biometria
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para acessar o app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        return null;
      }

      // Retorna apenas os dados de identificação (sem senha)
      final email = await _secureStorage.read(key: _keyEmail);
      final authProvider = await _secureStorage.read(key: _keyAuthProvider);
      final userId = await _secureStorage.read(key: _keyUserId);

      if (email == null || authProvider == null) {
        return null;
      }

      return {
        'email': email,
        'authProvider': authProvider,
        'userId': userId ?? '',
      };
    } on PlatformException catch (e) {
      debugPrint('Erro na autenticação biométrica: $e');
      return null;
    }
  }

  /// Verifica a biometria e retorna o usuário Firebase da sessão persistida.
  ///
  /// Modelo Zero Knowledge: após a verificação biométrica bem-sucedida,
  /// usa-se a sessão Firebase já mantida pelo SDK (sem reutilizar senha).
  /// Se a sessão expirou ou foi revogada, retorna null e o app deve solicitar
  /// login completo.
  Future<User?> signInWithBiometrics() async {
    try {
      final credentials = await authenticateAndGetCredentials();
      if (credentials == null) {
        return null;
      }

      // Usa a sessão Firebase persistida pelo SDK no Keychain/KeyStore.
      // Não há senha armazenada — a biometria é a única barreira de acesso.
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Força refresh do token para garantir que a sessão ainda é válida.
        await currentUser.getIdToken(true);
        return currentUser;
      }

      // Sessão expirada ou revogada — exige re-login completo.
      return null;
    } catch (e) {
      debugPrint('Erro ao fazer login com biometria: $e');
      return null;
    }
  }

  /// Limpa os dados de identificação salvos (chamado no logout completo)
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyAuthProvider);
    await _secureStorage.delete(key: _keyUserId);
    await _secureStorage.delete(key: _keyBiometricEnabled);
  }

  /// Desabilita o login por biometria (mas mantém credenciais)
  Future<void> disableBiometric() async {
    await _secureStorage.write(key: _keyBiometricEnabled, value: 'false');
  }

  /// Habilita o login por biometria
  Future<void> enableBiometric() async {
    await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
  }

  /// Verifica se o login por biometria está habilitado
  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _keyBiometricEnabled);
    return enabled == 'true';
  }

  /// Faz logout do Firebase (chamado quando o app é fechado)
  Future<void> signOutFirebase() async {
    await _auth.signOut();
  }
}
