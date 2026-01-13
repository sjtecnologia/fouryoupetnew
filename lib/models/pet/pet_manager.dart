import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:fouryoupet/helpers/localnotification.dart';
import 'package:fouryoupet/models/pet/prontuario/prontuarios.dart';

import '../user/userapp.dart';
import 'pesos/pesos.dart';
import 'pet.dart';
import 'vacinas/vacinas.dart';

class PetManager extends ChangeNotifier {
  List<Pet> pets = [];

  Pet? pet;

  Userapp? user;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  PetManager() {
    _subscription?.cancel();
    //_listenToPets();
  }

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String _search = '';

  String get search => _search;

  set search(String value) {
    _search = value;
    notifyListeners();
  }

  List<Pet> get filteredPets {
    final List<Pet> filteredPets = [];

    if (search.isEmpty) {
      filteredPets.addAll(pets);
    } else {
      filteredPets.addAll(pets
          .where((p) => p.name!.toLowerCase().contains(search.toLowerCase())));
    }
    return filteredPets;
  }

  List<Pet> findPetByUser(String? userid) {
    final List<Pet> findPetByUser = [];
    if (pets.isEmpty) _listenToPets();
    if (search.isNotEmpty)
      findPetByUser.addAll(pets
          .where((p) => p.user_id == userid)
          .where((p) => p.name!.toLowerCase().contains(search.toLowerCase())));
    else
      findPetByUser.addAll(pets.where((p) => p.user_id == userid));
    return findPetByUser;
  }

  void _listenToPets() async {
    _subscription = await firestore
        .collection('pet')
        .where('deleted', isEqualTo: false)
        .where('user_id', isEqualTo: user!.id)
        .snapshots()
        .listen((event) {
      pets.clear();
      for (final doc in event.docs) {
        pets.add(Pet.fromDocument(doc));
      }
    });
    notifyListeners();
  }

  getPesos(String id) async {
    final QuerySnapshot snapPesos = await firestore
        .collection('pet')
        .doc(id)
        .collection("pesos")
        .orderBy('datapeso')
        .get();
    return snapPesos.docs.map((doc) => doc.id).toList();
  }

  bool _editing = false;

  bool get editing => _editing;
  set editing(bool value) {
    _editing = value;
    notifyListeners();
  }

  void setVacinas(Pet pet) async {
    loading = true;
    pet.setVacinas(pet);
    loading = false;
  }

  void saveVacinas() async {
    loading = true;
    pet!.save();
    loading = false;
  }

  void setProntuarios(Pet pet) async {
    loading = true;
    pet.setProntuarios(pet);
    loading = false;
  }

  void setPesos(Pet pet) async {
    loading = true;
    pet.setPesos(pet);
    loading = false;
  }

  void saveProntuarios() async {
    loading = false;
  }

  Pet? findPetByID(String? id) {
    try {
      return pets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void removeVacina(Pet pet, Vacinas vacinas) {
    pet.vacinas!.removeWhere((v) => v == vacinas);
    pet.save();
    notifyListeners();
  }

  void removeProntuario(Pet pet, Prontuarios prontuarios) {
    pet.prontuarios!.removeWhere((p) => p == prontuarios);
    pet.save();
    notifyListeners();
  }

  void removePeso(Pet pet, Pesos peso) {
    pet.pesos!.removeWhere((p) => p == peso);
    pet.save();
    notifyListeners();
  }

  void delete(Pet pet) {
    pet.vacinas!.forEach((v) {
      v.aplic!.forEach((a) {
        Localnotification.cancelnotification(a.scheduleid as int);
      });
    });

    pet.delete();
    pets.removeWhere((p) => p.id == pet.id);
    notifyListeners();
  }

  void update(Pet pet) {
    pets.removeWhere((p) => p.id == pet.id);
    pets.add(pet);
    notifyListeners();
  }

  DateTime? _birth = DateTime.now();

  DateTime? get birth => _birth;

  set birth(DateTime? value) {
    _birth = value;
  }

  void updateBirth(DateTime? birth) {
    this.birth = birth;
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  void updateUser(Userapp? user) {
    this.user = user;
  }
}
