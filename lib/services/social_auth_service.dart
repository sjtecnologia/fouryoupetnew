import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class SocialAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Login com Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Erro ao fazer login com Google: $e');
      rethrow;
    }
  }

  // Login com Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // A Apple só envia o nome na PRIMEIRA autorização
      // Precisamos capturar e salvar no perfil do Firebase
      final givenName = appleCredential.givenName;
      final familyName = appleCredential.familyName;
      final appleEmail = appleCredential.email;

      if (userCredential.user != null) {
        String? displayName;

        // Montar o nome completo se disponível
        if (givenName != null || familyName != null) {
          displayName = [givenName, familyName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
        }

        // Atualizar o perfil do usuário no Firebase se temos novos dados
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }

        // Se a Apple forneceu email, atualizar também
        // (às vezes o usuário esconde o email real)
        if (appleEmail != null && appleEmail.isNotEmpty) {
          // O email já é salvo automaticamente pelo Firebase
          debugPrint('Apple email: $appleEmail');
        }

        // Recarregar o usuário para pegar os dados atualizados
        await userCredential.user!.reload();
      }

      return userCredential;
    } catch (e) {
      debugPrint('Erro ao fazer login com Apple: $e');
      rethrow;
    }
  }

  // Verificar se o dispositivo suporta biometria
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      return false;
    }
  }

  // Verificar biometrias disponíveis
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Erro ao obter biometrias disponíveis: $e');
      return [];
    }
  }

  // Autenticar com biometria
  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Por favor, autentique-se para acessar o app',
  }) async {
    try {
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      debugPrint('Erro na autenticação biométrica: $e');
      return false;
    }
  }

  // Deslogar
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
