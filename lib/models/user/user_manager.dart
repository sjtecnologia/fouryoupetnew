import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouryoupet/helpers/firebase_errors.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:fouryoupet/services/cepaberto_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fouryoupet/services/social_auth_service.dart';
import 'package:fouryoupet/services/biometric_auth_service.dart';
import 'package:fouryoupet/models/loyalty/loyalty_manager.dart';

class UserManager extends ChangeNotifier {
  final SocialAuthService _socialAuthService = SocialAuthService();
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final LoyaltyManager _loyaltyManager = LoyaltyManager();
  UserManager() {
    // Não carrega usuário automaticamente - o usuário precisa fazer login
    // ou usar biometria para entrar
    _findUserByID();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuthenticationService firebaseAuthenticationService =
      FirebaseAuthenticationService();

  Userapp? userapp;
  List<Address>? address;
  CompanyManager? companyManager;

  List<Userapp> alluser = [];

  late GoogleMapController _mapsController;

  get mapsController => _mapsController;

  double lat = 0.0;
  double long = 0.0;
  String erro = '';

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _editing = false;

  bool get editing => _editing;
  set editing(bool value) {
    _editing = value;
    notifyListeners();
  }

  getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      lat = posicao.latitude;
      long = posicao.longitude;
      try {
        await _mapsController
            .animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
      } catch (e) {
        await _mapsController
            .moveCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
      }
      //_mapsController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
    } catch (e) {
      erro = e.toString();
    }
    notifyListeners();
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;

    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }

  bool _checked = false;
  bool get checked => _checked;
  set checked(bool value) {
    _checked = value;
    notifyListeners();
  }

  bool get isLoggedIn => userapp != null && auth.currentUser != null;

  Future<void> resetpassord(String text,
      {required String emailAddress,
      Function? onFail,
      required Function onSuccess}) async {
    loading = true;
    try {
      await auth.sendPasswordResetEmail(email: emailAddress);
      onSuccess();
    } on Exception catch (e) {
      onFail!(e);
    }
    loading = false;
  }

  Future<void> signIn(
      {required Userapp userapp,
      Function? onFail,
      required Function onSuccess}) async {
    loading = true;

    try {
      if (userapp.email != null) {
        final UserCredential result = await auth.signInWithEmailAndPassword(
            email: userapp.email!, password: userapp.password!);

        await _loadCurrentUser(firebaseUser: result.user);

        // Salvar dados de identificação para login biométrico (sem senha)
        await _biometricAuthService.saveCredentials(
          email: userapp.email!,
          authProvider: 'email',
          userId: result.user!.uid,
        );
        // Limpar senha da memória imediatamente — modelo Zero Knowledge
        userapp.password = null;

        userapp.saveToken();

        onSuccess();
      }
    } on FirebaseAuthException catch (e, s) {
      onFail!(_handleFirebaseLoginWithCredentialsException(e, s));
    } on Exception catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      loading = false;
    }
    loading = false;
  }

  // Login com Google
  Future<void> signInWithGoogle({
    Function? onFail,
    required Function onSuccess,
  }) async {
    loading = true;
    try {
      final userCredential = await _socialAuthService.signInWithGoogle();
      if (userCredential != null) {
        await _loadCurrentUser(firebaseUser: userCredential.user);
        await _createOrUpdateSocialUser(userCredential.user!);
        // Salvar credenciais para login biométrico
        await _biometricAuthService.saveCredentials(
          email: userCredential.user!.email ?? '',
          authProvider: 'google',
          userId: userCredential.user!.uid,
        );
        if (userapp != null) {
          onSuccess();
        } else {
          onFail?.call(
              'Erro ao carregar dados do usuário após o login com Google');
        }
      }
    } catch (e) {
      onFail?.call('Erro ao fazer login com Google: $e');
    }
    loading = false;
  }

  // Login com Apple
  Future<void> signInWithApple({
    Function? onFail,
    required Function onSuccess,
  }) async {
    loading = true;
    try {
      final userCredential = await _socialAuthService.signInWithApple();
      if (userCredential != null) {
        await _loadCurrentUser(firebaseUser: userCredential.user);
        await _createOrUpdateSocialUser(userCredential.user!);
        // Salvar credenciais para login biométrico
        await _biometricAuthService.saveCredentials(
          email: userCredential.user!.email ?? '',
          authProvider: 'apple',
          userId: userCredential.user!.uid,
        );
        onSuccess();
      }
    } catch (e) {
      onFail?.call('Erro ao fazer login com Apple: $e');
    }
    loading = false;
  }

  // Autenticação biométrica - verifica apenas se pode autenticar
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _socialAuthService.canCheckBiometrics();
      if (!canCheck) {
        return false;
      }
      return await _socialAuthService.authenticateWithBiometrics();
    } catch (e) {
      debugPrint('Erro na autenticação biométrica: $e');
      return false;
    }
  }

  // Login com biometria - autentica e faz login
  Future<void> signInWithBiometrics({
    Function? onFail,
    required Function onSuccess,
  }) async {
    loading = true;
    try {
      // Verifica se há credenciais salvas
      final hasCredentials = await _biometricAuthService.hasStoredCredentials();
      if (!hasCredentials) {
        onFail?.call('Nenhuma credencial salva. Faça login primeiro.');
        loading = false;
        return;
      }

      // Obtém as credenciais após autenticação biométrica
      final credentials =
          await _biometricAuthService.authenticateAndGetCredentials();
      if (credentials == null) {
        onFail?.call('Falha na autenticação biométrica');
        loading = false;
        return;
      }

      // Usa a sessão Firebase persistida pelo SDK no Keychain/KeyStore.
      // A biometria é a barreira de acesso; não há senha armazenada localmente.
      final firebaseUser = auth.currentUser;
      if (firebaseUser != null) {
        await _loadCurrentUser(firebaseUser: firebaseUser);
        onSuccess();
      } else {
        // Sessão expirada ou revogada — força re-login completo
        onFail?.call('Sessão expirada. Por favor, faça login novamente.');
      }
    } catch (e) {
      onFail?.call('Erro ao fazer login com biometria: $e');
    }
    loading = false;
  }

  // Verificar se biometria está disponível E se há credenciais salvas
  Future<bool> isBiometricsAvailable() async {
    try {
      // Usa getBestAvailableBiometric para garantir que há biometria real disponível
      // (verifica hardware E matrícula, preferindo impressão digital)
      final bestBiometric =
          await _biometricAuthService.getBestAvailableBiometric();
      if (bestBiometric == null) return false;

      final hasCredentials = await _biometricAuthService.hasStoredCredentials();
      return hasCredentials;
    } catch (e) {
      return false;
    }
  }

  // Retorna o tipo de biometria disponível (para exibir ícone/texto correto na UI)
  Future<BiometricType?> getAvailableBiometricType() async {
    return await _biometricAuthService.getBestAvailableBiometric();
  }

  // Verificar se há credenciais salvas para login biométrico
  Future<bool> hasStoredCredentials() async {
    return await _biometricAuthService.hasStoredCredentials();
  }

  // Obter email salvo para exibir na tela de login
  Future<String?> getSavedEmail() async {
    return await _biometricAuthService.getSavedEmail();
  }

  // Obter provider salvo
  Future<String?> getSavedAuthProvider() async {
    return await _biometricAuthService.getSavedAuthProvider();
  }

  // Carregar usuário pelo ID (para login biométrico com providers sociais)
  // Criar ou atualizar usuário de login social no Firestore
  Future<void> _createOrUpdateSocialUser(User firebaseUser) async {
    try {
      final docRef = firestore.collection('users').doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Criar novo usuário
        await docRef.set({
          'name': firebaseUser.displayName ?? 'Usuário',
          'email': firebaseUser.email,
          'photo': firebaseUser.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'adminEnabled': false,
          'typeuser': 'C', // Cliente
        });
      } else {
        // Atualizar foto se mudou
        if (firebaseUser.photoURL != null) {
          await docRef.update({
            'photo': firebaseUser.photoURL,
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao criar/atualizar usuário social: $e');
    }
  }

  Future<void> _findUserByID() async {
    // Já não faz mais sentido carregar todos os usuários
    // Use findUserByID() para queries específicas
  }

  Future<Userapp?> findUserByID(String? id) async {
    if (id == null) return null;
    try {
      final doc = await firestore.collection('users').doc(id).get();
      if (!doc.exists) return null;
      return Userapp.fromDocument(doc);
    } catch (e) {
      debugPrint('Erro ao buscar usuário por ID: $e');
      return null;
    }
  }

  Future<String?> findUserByCompanyID(String? id) async {
    if (id == null) return null;
    try {
      final snapQuery = await firestore
          .collection('users')
          .where('companyID', isEqualTo: id)
          .limit(1)
          .get();
      if (snapQuery.docs.isEmpty) return null;
      return snapQuery.docs.first.id;
    } catch (e) {
      debugPrint('Erro ao buscar usuário por companyID: $e');
      return null;
    }
  }

  getToken(String id) async {
    final QuerySnapshot snapToken = await firestore
        .collection('users')
        .doc(id)
        .collection("tokens")
        .orderBy('updatedAt')
        .get();
    return snapToken.docs.map((doc) => doc.id).toList();
  }

  Future<Userapp?> finduser() async {
    if (userapp == null) {
      await _loadCurrentUser();
    } else {
      await reloadAdminStatus(); // Recarrega o status de admin
    }
    return userapp;
  }

  // Método para forçar recarregamento completo dos dados do usuário
  Future<void> reloadUserData() async {
    debugPrint('DEBUG: Forcing user data reload');
    userapp = null;
    await _loadCurrentUser();
  }

  _handleFirebaseLoginWithCredentialsException(
      FirebaseAuthException e, StackTrace s) {
    if (e.code == 'user-disabled') {
      return 'O usuário informado está desabilitado.';
    } else if (e.code == 'user-not-found') {
      return 'O usuário informado não está cadastrado.';
    } else if (e.code == 'invalid-email') {
      return 'O domínio do e-mail informado é inválido.';
    } else if (e.code == 'wrong-password') {
      return 'A senha informada está incorreta.';
    } else {
      return 'Outro problema';
    }
  }

  Future<void> reloadAdminStatus() async {
    if (userapp?.id != null) {
      final docAdmin =
          await firestore.collection('admins').doc(userapp!.id).get();
      userapp!.admin = docAdmin.exists;
      notifyListeners();
    }
  }

  Future<void> setAddress(Address address) async {
    loading = true;
    if (this.userapp != null) this.userapp?.setAddress(address);

    loading = false;
  }

  Future<void> setChecked(bool checked) async {
    loading = true;
    this.userapp!.checked = checked;
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signUp({
    required Userapp userapp,
    String? referralCode,
    Function? onFail,
    required Function onSuccess,
  }) async {
    loading = true;
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
          email: userapp.email!, password: userapp.password!);

      // Limpar senhas da memória imediatamente após autenticação
      userapp.password = null;
      userapp.confirmPassword = null;

      userapp.id = result.user!.uid;

      // Gerar código de indicação único para o novo usuário
      userapp.referralCode = _loyaltyManager.generateReferralCode(userapp.id!);

      // Se foi indicado por alguém, validar e vincular
      if (referralCode != null && referralCode.isNotEmpty) {
        final referrerId =
            await _loyaltyManager.validateReferralCode(referralCode);
        if (referrerId != null) {
          userapp.referredBy = referrerId;
          debugPrint('✅ Usuário indicado por: $referrerId');
        } else {
          debugPrint('⚠️ Código de indicação inválido: $referralCode');
        }
      }

      userapp.hasCompletedFirstPurchase = false;
      this.userapp = userapp;

      await userapp.saveData();
      userapp.saveToken();

      onSuccess();
    } on PlatformException catch (e) {
      loading = false;
      onFail!(getErrorString(e.code));
    }
    loading = false;
  }

  /// Logout padrão - mantém credenciais para login biométrico
  void signOut() {
    auth.signOut();
    userapp = null;
    notifyListeners();
  }

  /// Logout completo - remove credenciais salvas também
  Future<void> signOutCompletely() async {
    await _biometricAuthService.clearCredentials();
    auth.signOut();
    userapp = null;
    notifyListeners();
  }

  /// Suspende a sessão na UI sem invalidar o Firebase Auth.
  /// A sessão Firebase (refresh token) é mantida pelo SDK para permitir
  /// o login biométrico na próxima abertura sem armazenar senha.
  Future<void> signOutFirebaseOnly() async {
    userapp = null;
    notifyListeners();
  }

  DocumentReference get firestoreRef =>
      firestore.collection('users').doc(auth.currentUser?.uid);
  CollectionReference get groupReference => firestoreRef.collection('messeges');

  getChats() async {
    return groupReference.orderBy("time").snapshots();
  }

  Future<void> _loadCurrentUser({User? firebaseUser}) async {
    try {
      final User? currentUser = firebaseUser ?? auth.currentUser;

      if (currentUser != null) {
        final DocumentSnapshot docUser =
            await firestore.collection('users').doc(currentUser.uid).get();

        if (docUser.exists) {
          userapp = Userapp.fromDocument(docUser);

          if (userapp != null) {
            userapp!.saveToken();
            await getChats();

            final docAdmin =
                await firestore.collection('admins').doc(userapp!.id).get();
            if (docAdmin.exists) {
              userapp!.admin = true;
            }
          }
        } else {
          debugPrint(
              'DEBUG: User document does not exist in Firestore - Creating new document');
          // Recriar documento do usuário no Firestore
          await _createUserDocument(currentUser);
        }

        notifyListeners();
      } else {
        debugPrint('DEBUG: No current user found');
        userapp = null;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Error loading current user: $e');
      debugPrint('DEBUG: Stack trace: $stackTrace');
      userapp = null;
      notifyListeners();
    }
  }

  // Método para recriar documento do usuário no Firestore
  Future<void> _createUserDocument(User firebaseUser) async {
    try {
      debugPrint('DEBUG: Creating user document for ${firebaseUser.email}');

      // Criar dados básicos do usuário
      final userData = {
        'name': firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'Usuário',
        'email': firebaseUser.email,
        'createdAt': FieldValue.serverTimestamp(),
        'address': [],
        'checked': false,
      };

      // Salvar no Firestore
      await firestore.collection('users').doc(firebaseUser.uid).set(userData);

      // Recarregar o usuário
      final docUser =
          await firestore.collection('users').doc(firebaseUser.uid).get();
      userapp = Userapp.fromDocument(docUser);

      debugPrint(
          'DEBUG: User document created successfully - Name: ${userapp?.name}');

      if (userapp != null) {
        userapp!.saveToken();
        await getChats();
      }
    } catch (e) {
      debugPrint('DEBUG: Error creating user document: $e');
      userapp = null;
    }
  }

  void removeAddress(Address address) {
    userapp!.address!.removeWhere((a) => a == address);
    userapp?.saveData();
    notifyListeners();
  }

  Future<void> getAddress(String cep) async {
    final cepAbertoService = CepAbertoService();
    loading = true;
    editing = true;
    try {
      final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);
      if (userapp?.address == null) {
        userapp?.address = [];
      }
      userapp!.address?.add(Address(
        street: cepAbertoAddress.logradouro,
        district: cepAbertoAddress.bairro,
        zipCode: cepAbertoAddress.cep,
        city: cepAbertoAddress.cidade.nome,
        state: cepAbertoAddress.estado.sigla,
        lat: cepAbertoAddress.latitude,
        long: cepAbertoAddress.longitude,
        checked: true,
      ));
      loading = false;
      editing = false;
    } catch (e) {
      // Limpa o zipCode do address para resetar o card e permitir nova consulta
      if (userapp?.address != null && userapp!.address!.isNotEmpty) {
        userapp!.address!.last.zipCode = null;
      }
      loading = false;
      editing = true;
      notifyListeners();
      return Future.error('CEP Inválido');
    }
  }

  void delete() async {
    await firestore.collection('users').doc(userapp!.id).delete();
    await auth.currentUser!.delete();
    signOut();
    notifyListeners();
  }

  bool get adminEnabled => userapp != null && userapp!.admin;
}
