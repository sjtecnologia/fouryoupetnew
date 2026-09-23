// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../screens/categories/categories_screen.dart'; // Certifique-se que CategoriesScreen está no lugar certo
import '../../services/cepaberto_service.dart';
import 'company.dart';

GlobalKey<NavigatorState> appKey = GlobalKey<
    NavigatorState>(); // Definição provisória, ajuste conforme seu projeto

class CompanyManager extends ChangeNotifier {
  CompanyManager({this.homeclic}) {
    getCheck();
    loadAllCompanys();
  }

  // Adicione este método no company_manager.dart se não existir
  Future<void> updateCompanyData(Company updatedCompany) async {
    try {
      await firestore
          .collection('companys')
          .doc(updatedCompany.id)
          .update(updatedCompany.toMap());

      company = updatedCompany;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar empresa: $e');
      rethrow;
    }
  }

  int? homeclic;
  Userapp? userapp;
  LocationPermission? permissao;

  Set<Marker> markers = <Marker>{};
  GoogleMapController? _mapsController;

  GoogleMapController? get mapsController => _mapsController;

  double lat = 0.0;
  double long = 0.0;
  String erro = '';
  String lpermissao = '';
  String? _errorMessage;

  onMapCreated(GoogleMapController gmc) async {
    _mapsController = gmc;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Company? company;

  Address? address;

  List<Company> _allCompany = [];
  bool _isCompanyListLoading = false;

  List<Company> get allCompany => List.unmodifiable(_allCompany);

  String _search = '';

  String get search => _search;

  set search(String value) {
    _search = value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _isCheckingStatus = false;
  bool get isCheckingStatus => _isCheckingStatus;

  String? get errorMessage => _errorMessage;

  List<Company> get filteredCompanys {
    final List<Company> result = [];

    if (search.isEmpty && homeclic == 1) {
      result.addAll(_allCompany.where((p) => p.shop == true));
    } else {
      if (homeclic == 1) {
        if (search.isNotEmpty) {
          result.addAll(_allCompany.where((p) => p.shop == true).where(
              (p) => p.name!.toLowerCase().contains(search.toLowerCase())));
        } else {
          result.addAll(_allCompany.where((p) => p.shop == true));
        }
      } else {
        switch (homeclic) {
          case 2:
            if (search.isNotEmpty) {
              result.addAll(_allCompany.where((p) => p.cut == true).where(
                  (p) => p.name!.toLowerCase().contains(search.toLowerCase())));
            } else {
              result.addAll(_allCompany.where((p) => p.cut == true));
            }
            break;
          case 3:
            if (search.isNotEmpty) {
              result.addAll(_allCompany.where((p) => p.vet == true).where(
                  (p) => p.name!.toLowerCase().contains(search.toLowerCase())));
            } else {
              result.addAll(_allCompany.where((p) => p.vet == true));
            }
            break;
          case 4:
            if (search.isNotEmpty) {
              result.addAll(_allCompany.where((p) => p.ht == true).where(
                  (p) => p.name!.toLowerCase().contains(search.toLowerCase())));
            } else {
              result.addAll(_allCompany.where((p) => p.ht == true));
            }
            break;
        }
      }
    }
    return result;
  }

  Future<void> updatekeyword() async {
    List<String> _generateKeywords(String text) {
      final words = removeDiacritics(text).toLowerCase().split(' ');
      final keywords = <String>[];
      for (var word in words) {
        for (var i = 0; i < word.length; i++) {
          for (var j = i + 1; j <= word.length; j++) {
            keywords.add(word.substring(i, j));
          }
        }
      }
      return keywords;
    }

    final companyCollection = FirebaseFirestore.instance.collection('companys');
    final querySnapshot = await companyCollection.get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final companyName = data['name'] as String?;

      if (companyName != null) {
        final keywords = _generateKeywords(companyName);
        await doc.reference.update({'keywords': keywords});
        debugPrint('Documento ${doc.id} atualizado com sucesso!');
      } else {
        debugPrint('Nome do company não encontrado no documento ${doc.id}');
      }
    }
    debugPrint('Atualização concluída!');
  }

  Future<void> removeAddress() async {
    if (company != null) {
      company!.address = null;
      notifyListeners();
    }
  }

  Future<void> setAddress(Address address) async {
    loading = true;
    if (company != null) {
      this.company!.address = address;
    }
    loading = false;
  }

  Future<Address?> getAddressfull(String cep) async {
    final cepAbertoService = CepAbertoService();
    loading = true;

    try {
      final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);
      address = Address(
        street: cepAbertoAddress.logradouro,
        district: cepAbertoAddress.bairro,
        zipCode: cep,
        city: cepAbertoAddress.cidade.nome,
        state: cepAbertoAddress.estado.sigla,
        lat: cepAbertoAddress.latitude,
        long: cepAbertoAddress.longitude,
      );
      company?.address = address;
      return address;
    } catch (e) {
      _errorMessage = 'Erro ao buscar CEP: $e';
      return null;
    } finally {
      loading = false;
    }
  }

  Future<void> getAddress(String cep) async {
    final cepAbertoService = CepAbertoService();
    loading = true;

    try {
      final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);
      if (company != null) {
        company!.address = Address(
          street: cepAbertoAddress.logradouro,
          district: cepAbertoAddress.bairro,
          zipCode: cep,
          city: cepAbertoAddress.cidade.nome,
          state: cepAbertoAddress.estado.sigla,
          lat: cepAbertoAddress.latitude,
          long: cepAbertoAddress.longitude,
        );
        setAddress(company!.address as Address);
      }
    } catch (e) {
      _errorMessage = 'CEP Inválido: $e';
      throw ('CEP Inválido'); // Lançar erro para quem chamou
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllCompanys() async {
    if (_isCompanyListLoading) return;
    _isCompanyListLoading = true;
    loading = true;
    _errorMessage = null;

    try {
      List<Company> newLoadedCompanies = [];
      List<Company> filteredByDistance = [];

      final QuerySnapshot snapProductstd = await firestore
          .collection('companys')
          .where('id', isEqualTo: '0')
          .get();
      if (snapProductstd.docs.isNotEmpty) {
        newLoadedCompanies.add(Company.fromDocument(snapProductstd.docs.first));
      }

      final QuerySnapshot snapProducts = await firestore
          .collection('companys')
          .where('active', isEqualTo: true)
          .orderBy('name')
          .get();
      for (var doc in snapProducts.docs) {
        newLoadedCompanies.add(Company.fromDocument(doc));
      }

      if (userapp != null &&
          userapp!.address != null &&
          userapp!.address!.isNotEmpty == true) {
        var addressuser =
            userapp!.address!.firstWhereOrNull((u) => u.checked == true);
        if (addressuser != null) {
          for (var c in newLoadedCompanies) {
            if (c.address != null &&
                c.address!.lat != null &&
                c.address!.long != null &&
                c.maxkm != null) {
              final distancia = await GeolocatorPlatform.instance
                      .distanceBetween(
                          addressuser.lat!.toDouble(),
                          addressuser.long!.toDouble(),
                          c.address!.lat!.toDouble(),
                          c.address!.long!.toDouble()) /
                  1000;

              if (distancia.toDouble() <= c.maxkm!.toDouble() || c.id == '0') {
                c.distancia = distancia;
                filteredByDistance.add(c);
              }
            } else if (c.id == '0') {
              filteredByDistance.add(c);
            }
          }
        } else {
          // Se userapp.address existe, mas nenhum está checado
          // Trate como se não houvesse endereço de usuário ou use a posição atual
          await _filterByCurrentLocation(
              newLoadedCompanies, filteredByDistance);
        }
      } else {
        await _filterByCurrentLocation(newLoadedCompanies, filteredByDistance);
      }

      _allCompany = filteredByDistance;

      markers.clear();
      for (var p in _allCompany) {
        if (p.id != "0" &&
            p.id != "-1" &&
            p.address != null &&
            p.address!.lat != null &&
            p.address!.long != null) {
          markers.add(
            Marker(
              visible: true,
              icon: await BitmapDescriptor.fromAssetImage(
                  const ImageConfiguration(), 'images/loc.png'),
              infoWindow: InfoWindow(
                title: p.name,
                snippet: '${p.address!.street!}, ${p.address!.number!}',
                onTap: () {
                  if (appKey.currentState?.context != null) {
                    Navigator.push(
                        appKey.currentState!.context,
                        MaterialPageRoute(
                            builder: (context) => CategoriesScreen(
                                  company: p,
                                  homeclic: homeclic,
                                )));
                  } else {
                    debugPrint(
                        'Erro: Contexto do Navigator não disponível para navegação.');
                  }
                },
              ),
              markerId: MarkerId(p.id!),
              position: LatLng(p.address!.lat!, p.address!.long!),
            ),
          );
        }
      }
    } catch (e, stack) {
      _errorMessage = 'Erro ao carregar empresas: $e';
      debugPrint('Erro ao carregar empresas: $e\n$stack');
      _allCompany = [];
    } finally {
      _isCompanyListLoading = false;
      loading = false;
    }
  }

  Future<Map<String, dynamic>> checkSubscriptionStatus(
      Company companyToCheck) async {
    try {
      _isCheckingStatus = true;
      notifyListeners();

      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('checkSubscriptionStatus');

      final result = await callable.call({
        'companyId': companyToCheck.id,
      });

      final data = result.data as Map<String, dynamic>;

      // Se a verificação foi bem sucedida, atualiza os dados
      if (data['success'] == true) {
        // Atualiza os dados da empresa
        companyToCheck.subscriptionStatus = data['status'];
        companyToCheck.subscriptionId = data['subscriptionId'];

        // Atualiza no Firestore
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyToCheck.id)
            .update({
          'subscriptionStatus': data['status'],
          'subscriptionId': data['subscriptionId'],
          'lastSubscriptionCheck': FieldValue.serverTimestamp(),
        });

        // Atualiza a lista local se a empresa estiver nela
        final index = _allCompany.indexWhere((c) => c.id == companyToCheck.id);
        if (index != -1) {
          _allCompany[index].subscriptionStatus = data['status'];
          _allCompany[index].subscriptionId = data['subscriptionId'];
        }
      }

      return data;
    } catch (e) {
      debugPrint('Erro ao verificar status da assinatura: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _isCheckingStatus = false;
      notifyListeners();
    }
  }

  // Função auxiliar para filtrar por localização atual
  Future<void> _filterByCurrentLocation(
      List<Company> sourceCompanies, List<Company> destinationList) async {
    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Serviço de localização desabilitado');
        // Adicionar todas as empresas se localização não estiver disponível
        destinationList.addAll(sourceCompanies);
        return;
      }

      // Verificar permissão de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Permissão de localização negada');
          // Adicionar todas as empresas se permissão for negada
          destinationList.addAll(sourceCompanies);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Permissão de localização negada permanentemente');
        // Adicionar todas as empresas se permissão for negada permanentemente
        destinationList.addAll(sourceCompanies);
        return;
      }

      // Obter posição atual
      final Position posicaoatual = await Geolocator.getCurrentPosition();

      for (var c in sourceCompanies) {
        if (c.address != null &&
            c.address!.lat != null &&
            c.address!.long != null &&
            c.maxkm != null) {
          final distancia = await GeolocatorPlatform.instance.distanceBetween(
                  posicaoatual.latitude.toDouble(),
                  posicaoatual.longitude.toDouble(),
                  c.address!.lat!.toDouble(),
                  c.address!.long!.toDouble()) /
              1000;

          if (distancia.toDouble() <= c.maxkm!.toDouble() || c.id == '0') {
            c.distancia = distancia;
            destinationList.add(c);
          }
        } else if (c.id == '0') {
          destinationList.add(c);
        }
      }
    } catch (e) {
      _errorMessage =
          'Erro ao obter localização atual para filtrar empresas: $e';
      debugPrint('Erro ao obter localização atual: $e');
      // Se não conseguir a localização, adicionar todas as empresas
      destinationList.addAll(sourceCompanies);
    }
  }

  Future<void> _findCompanyByID() async {
    final QuerySnapshot snapCompanys =
        await firestore.collection('companys').get();
    _allCompany =
        snapCompanys.docs.map((d) => Company.fromDocument(d)).toList();
    notifyListeners();
  }

  Company? findCompanyByID(String? id) {
    if (id == null) return null;
    return _allCompany.firstWhereOrNull((c) => c.id == id);
  }

  Future<Company?>? findCompanyNameEndByID(String id) async {
    final QuerySnapshot snapCompanys =
        await firestore.collection('companys').where('id', isEqualTo: id).get();
    if (snapCompanys.docs.isNotEmpty) {
      return Company.fromDocument(snapCompanys.docs.last);
    }
    return null;
  }

  Future<Company?>? findCompanyByName(String name) async {
    final QuerySnapshot snapCompanys = await firestore
        .collection('companys')
        .where('name', isEqualTo: name)
        .get();
    if (snapCompanys.docs.isNotEmpty) {
      return Company.fromDocument(snapCompanys.docs.last);
    }
    return null;
  }

  Future<Company?> findCompanyByID2(String? id) async {
    if (id == null) return null;
    _allCompany.clear();
    await _findCompanyByID();
    return _allCompany.firstWhereOrNull((c) => c.id == id);
  }

  Future<Company?> findCompanyByIDf(String? id) async {
    if (id == null) return null;
    if (_allCompany.isEmpty) await loadAllCompanys();
    return _allCompany.firstWhereOrNull((c) => c.id == id);
  }

  Company? findCompanyByShop(String? id) {
    return _allCompany.firstWhereOrNull((c) => c.shop == true);
  }

  Company? findCompanyByVet(String? id) {
    return _allCompany.firstWhereOrNull((c) => c.vet == true);
  }

  Company? findCompanyByCut(String? id) {
    return _allCompany.firstWhereOrNull((c) => c.cut == true);
  }

  Company? findCompanyByHt(String? id) {
    return _allCompany.firstWhereOrNull((c) => c.ht == true);
  }

  void updateUser(Userapp? user) async {
    this.userapp = user;
    await loadAllCompanys();
  }

  Future<void> update(Company company) async {
    _allCompany.removeWhere((c) => c.id == company.id);
    _allCompany.add(company);
    notifyListeners();
  }

  getPosicao() async {
    try {
      Position posicao = await posicaoAtual();
      lat = posicao.latitude;
      long = posicao.longitude;
      if (_mapsController != null) {
        try {
          await _mapsController!
              .animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
        } catch (e) {
          await _mapsController!
              .moveCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
        }
      }
    } catch (e) {
      erro = e.toString();
      debugPrint(erro);
    }
    notifyListeners();
  }

  getCheck() async {
    try {
      LocationPermission lperm = await check();
      lpermissao = lperm.name;
    } catch (e) {
      erro = e.toString();
      debugPrint(erro);
    }
    notifyListeners();
  }

  Future<LocationPermission> check() async {
    permissao = await Geolocator.checkPermission();
    return permissao!;
  }

  Future<Position> posicaoAtual() async {
    permissao = await Geolocator.checkPermission();

    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }

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
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
