import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço para gerenciar autenticação biométrica
///
/// Fluxo:
/// 1. Usuário faz login (email/senha ou rede social)
/// 2. Credenciais são salvas de forma segura
/// 3. Quando o app é fechado, faz logout do Firebase
/// 4. Na próxima abertura, se tiver credenciais salvas, permite login com biometria
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

  // Chaves para armazenamento seguro
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyAuthProvider = 'saved_auth_provider';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyUserId = 'saved_user_id';

  /// Salva as credenciais após login bem-sucedido
  Future<void> saveCredentials({
    required String email,
    String? password,
    required String
        authProvider, // 'email', 'google', 'apple', 'facebook', 'twitter'
    required String userId,
  }) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    if (password != null) {
      await _secureStorage.write(key: _keyPassword, value: password);
    }
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
  /// Prioridade: impressão digital > rosto > íris > strong genérico.
  /// Retorna null se nenhuma biometria estiver disponível ou configurada.
  Future<BiometricType?> getBestAvailableBiometric() async {
    try {
      final canUse = await canUseBiometrics();
      if (!canUse) return null;

      final available = await getAvailableBiometrics();
      if (available.isEmpty) return null;

      // Prefere impressão digital no Android
      if (available.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
      // Aceita reconhecimento facial
      if (available.contains(BiometricType.face)) {
        return BiometricType.face;
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

      // Retorna as credenciais salvas
      final email = await _secureStorage.read(key: _keyEmail);
      final password = await _secureStorage.read(key: _keyPassword);
      final authProvider = await _secureStorage.read(key: _keyAuthProvider);
      final userId = await _secureStorage.read(key: _keyUserId);

      if (email == null || authProvider == null) {
        return null;
      }

      return {
        'email': email,
        'password': password ?? '',
        'authProvider': authProvider,
        'userId': userId ?? '',
      };
    } on PlatformException catch (e) {
      debugPrint('Erro na autenticação biométrica: $e');
      return null;
    }
  }

  /// Faz login com as credenciais salvas após autenticação biométrica
  Future<User?> signInWithBiometrics() async {
    try {
      final credentials = await authenticateAndGetCredentials();
      if (credentials == null) {
        return null;
      }

      final authProvider = credentials['authProvider'];
      final email = credentials['email']!;
      final password = credentials['password']!;

      // Se for login por email/senha
      if (authProvider == 'email' && password.isNotEmpty) {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user;
      }

      // Para provedores sociais (Google, Apple, Facebook, Twitter)
      // O usuário precisa fazer login novamente pela rede social
      // pois não podemos armazenar tokens de acesso de forma segura
      // Retornamos null para indicar que o login social deve ser refeito
      return null;
    } catch (e) {
      debugPrint('Erro ao fazer login com biometria: $e');
      return null;
    }
  }

  /// Limpa as credenciais salvas (chamado no logout completo)
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
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
