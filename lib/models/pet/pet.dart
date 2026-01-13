import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fouryoupet/helpers/localnotification.dart';

import 'package:fouryoupet/models/pet/prontuario/prontuarios.dart';
import 'package:fouryoupet/models/pet/vacinas/vacinas.dart';

import 'package:uuid/uuid.dart';

import '../user/userapp.dart';
import 'pesos/pesos.dart';
import 'vacinas/vacinasaplic.dart';

class Pet extends ChangeNotifier {
  final Userapp? userapp;

  Pet({
    this.userapp,
    this.user_id,
    this.id,
    this.name,
    this.birth,
    this.category_id,
    this.breed,
    this.color,
    this.size,
    this.pedigree,
    this.castrado,
    this.genero_id,
    this.images,
    this.vacinas,
    this.pesos,
    this.prontuarios,
    this.deleted = false,
    this.datainivacinas,
  }) {
    images = images ?? [];
    vacinas = vacinas ?? [];
    prontuarios = prontuarios ?? [];
    pesos = pesos ?? [];
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('pet/$id');
  Reference get storageRef => storage.ref().child('pet').child(id!);

  String? user_id;
  String? id;
  String? name;
  DateTime? birth;
  String? category_id;
  String? breed;
  String? color;
  String? size;
  String? genero_id;
  List<String>? images;
  List<dynamic>? newImages;
  List<Vacinas>? vacinas;
  List<dynamic>? newVacinas;
  List<Prontuarios>? prontuarios;
  List<Pesos>? pesos;
  bool? deleted;
  bool? pedigree;
  bool? castrado;
  bool _loading = false;
  bool get loading => _loading;
  DateTime? datainivacinas;
  DateTime? dtnewaplic;
  String? petcat;
  String? petgen;
  String? idadepet;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Pet.fromDocument(DocumentSnapshot document, {this.userapp}) {
    id = document.id;
    user_id = document['user_id'] as String?;
    name = document['name'] as String?;

    birth = (document.get('birth') as Timestamp).toDate();
    category_id = document['category_id'] as String?;
    breed = document['breed'] as String?;
    color = document['color'] as String?;
    size = document['size'] as String?;
    deleted = (document.get('deleted') ?? false) as bool;
    pedigree = document['pedigree'] as bool?;

    Map<String, dynamic> dataMap = document.data() as Map<String, dynamic>;
    if (dataMap.containsKey('genero_id'))
      genero_id = (document.get('genero_id') ?? '0') as String;
    if (dataMap.containsKey('castrado'))
      castrado = (document.get('castrado') ?? false) as bool;
    if (dataMap.containsKey('images'))
      images = List<String>.from(document.get('images') as List<dynamic>);

    if (dataMap.containsKey('datainivacinas') &&
        document.get('datainivacinas').toString() != '' &&
        document.get('datainivacinas') != null)
      datainivacinas = (document.get('datainivacinas') as Timestamp).toDate();

    if (dataMap.containsKey('vacinas')) {
      vacinas = (document.get('vacinas') as List)
          .map((e) => Vacinas.fromMap(e))
          .toList();
    }
    if (dataMap.containsKey('pesos')) {
      pesos =
          (document.get('pesos') as List).map((e) => Pesos.fromMap(e)).toList();
    }
    if (dataMap.containsKey('prontuarios')) {
      prontuarios = (document.get('prontuarios') as List)
          .map((add) => Prontuarios.fromMap(add))
          .toList();
    }
    if (genero_id != null) {
      switch (genero_id.toString()) {
        case '1':
          {
            petgen = 'Macho';
          }
          break;
        case '2':
          {
            petgen = 'Fêmea';
          }
          break;
        default:
          {
            petcat = 'Selecionar';
          }
          break;
      }
    }
    if (category_id != null) {
      switch (category_id.toString()) {
        case '1':
          {
            petcat = 'Cachorro';
          }
          break;
        case '2':
          {
            petcat = 'Gato';
          }
          break;
        case '3':
          {
            petcat = 'Peixe';
          }
          break;
        case '4':
          {
            petcat = 'Passaro';
          }
          break;
        case '5':
          {
            petcat = 'Roedor';
          }
          break;
        case '6':
          {
            petcat = 'Réptil';
          }
          break;
        default:
          {
            petcat = 'Selecionar';
          }
          break;
      }
    }
    int idade = DateTime.now().year - birth!.year;
    if (DateTime.now().month < birth!.month) {
      idade--;
    } else if (DateTime.now().month == birth!.month) {
      if (DateTime.now().day < birth!.day) idade--;
    }
    idadepet = idade.toString();
  }

  List<Map<String, dynamic>> exportVacinasList() {
    return vacinas!.map((vacinas) => vacinas.toMap()).toList();
  }

  List<Map<String, dynamic>> exportProntuariosList() {
    return prontuarios!.map((prontuarios) => prontuarios.toMap()).toList();
  }

  List<Map<String, dynamic>> exportPesosList() {
    return pesos!.map((pesos) => pesos.toMap()).toList();
  }

  Future<void> save() async {
    var som;
    var somios;
    switch (category_id) {
      case '1':
        {
          som = 'notification3';
          somios = 'notification3.aiff';
        }
        break;

      case '2':
        {
          som = 'notification1';
          somios = 'notification1.aiff';
        }
        break;
      case '4':
        {
          som = 'notification2';
          somios = 'notification2.aiff';
        }
        break;
    }
    loading = true;

    // --- NOVO CÓDIGO INSERIDO AQUI ---
    // Adiciona uma pesagem padrão se a lista de pesos estiver vazia ou nula
    if (pesos == null || pesos!.isEmpty) {
      print(
          'Verificando pesos: Lista de pesos vazia ou nula. Adicionando peso padrão.');
      pesos ??=
          []; // Garante que a lista de pesos esteja inicializada se for nula
      pesos!.add(Pesos(
        peso: "2.0", // Peso padrão como String, conforme a classe Pesos
        datapeso: DateTime.now(), // Data e hora atual
      ));
      print('Peso padrão (2.0 kg) adicionado para ${name ?? 'este pet'}.');
    } else {
      print(
          'Verificando pesos: Lista de pesos já contém ${pesos!.length} entradas. Nenhum peso padrão adicionado.');
    }
    // --- FIM DO NOVO CÓDIGO ---
    if (vacinas!.length < 1) {
      var vacina = Vacinas();
      var vacina2 = Vacinas();

      vacina.name = 'Antirrábica';
      vacina.aplic = [];

      vacina2.name = 'V8/V10';
      vacina2.aplic = [];

      var dt = datainivacinas!.year;
      if (vacina.aplic != null && vacina.aplic!.length > 0) {}

      while (dt <= DateTime.now().year + 1) {
        Vacinasaplic aplic = Vacinasaplic();
        String dtmonth;
        String dtday;
        if (datainivacinas!.month.toString().length == 1) {
          dtmonth = '0' + datainivacinas!.month.toString();
        } else {
          dtmonth = datainivacinas!.month.toString();
        }
        if (datainivacinas!.day.toString().length == 1) {
          dtday = '0' + datainivacinas!.day.toString();
        } else {
          dtday = datainivacinas!.day.toString();
        }

        aplic.aplicated = false;
        aplic.dataaplicacao = DateTime.parse(
            dt.toString() + '-' + dtmonth + '-' + dtday + ' 09:00:00');

        aplic.lote = null;
        aplic.marca = null;
        int id = Random().nextInt(50000);
        Localnotification.showNotificationscheduled(
          som: som,
          somios: somios,
          id: id,
          title: 'Lembrete de Vacinação',
          body: 'Olá, não esqueça da aplicação da vacina ' +
              vacina.name.toString() +
              'do(a) ' +
              name.toString() +
              ' dia: ' +
              dtday +
              '/' +
              dtmonth +
              '/' +
              dt.toString(),
          dateTime: DateTime.parse(
              dt.toString() + '-' + dtmonth + '-' + dtday + ' 09:00:00'),
        );
        aplic.scheduleid = id;
        vacina.aplic!.add(aplic);
        id = Random().nextInt(50000);
        Localnotification.showNotificationscheduled(
          id: id,
          som: som,
          somios: somios,
          title: 'Lembrete de Vacinação',
          body: 'Olá, não esqueça da aplicação da vacina ' +
              vacina.name.toString() +
              'do(a) ' +
              name.toString() +
              ' dia: ' +
              dtday +
              '/' +
              dtmonth +
              '/' +
              dt.toString(),
          dateTime: DateTime.parse(
              dt.toString() + '-' + dtmonth + '-' + dtday + ' 09:00:00'),
        );
        aplic.scheduleid = id;
        vacina2.aplic!.add(aplic);

        dt++;
      }

      vacinas!.add(vacina);
      vacinas!.add(vacina2);
    }
    if (vacinas!.last.aplic == null || vacinas!.last.aplic!.length == 0) {
      var vacina = vacinas!.last;
      var dt = datainivacinas!.year;
      var day = datainivacinas!.day.toString();
      if (day.length <= 1) day = '0' + day;
      var month = datainivacinas!.month.toString();
      if (month.length <= 1) month = '0' + month;

      vacina.aplic = [];
      while (dt <= DateTime.now().year + 1) {
        Vacinasaplic aplic = Vacinasaplic();
        aplic.aplicated = false;
        aplic.dataaplicacao = DateTime.parse(
            dt.toString() + '-' + month + '-' + day + ' 09:00:00');
        aplic.lote = null;
        aplic.marca = null;
        int id = Random().nextInt(50000);
        Localnotification.showNotificationscheduled(
          som: som,
          somios: somios,
          id: id,
          title: 'Lembrete de Vacinação',
          body: 'Olá, não esqueça da aplicação da vacina ' +
              vacina.name.toString() +
              'do(a) ' +
              name.toString() +
              ' dia: ' +
              day +
              '/' +
              month +
              '/' +
              dt.toString(),
          dateTime: DateTime.parse(
              dt.toString() + '-' + month + '-' + day + ' 09:00:00'),
        );

        aplic.scheduleid = id;
        vacina.aplic!.add(aplic);

        dt++;
      }

      vacinas!.remove(vacina);
      vacinas!.add(vacina);
    }
    for (var i = 0; i < vacinas!.length; i++) {
      for (var x = 0; x < vacinas![i].aplic!.length; x++) {
        if (vacinas![i].aplic!.last.aplicated == true &&
            vacinas![i].aplic!.last.incnewaplic == true) {
          Vacinasaplic aplic = Vacinasaplic();
          aplic.aplicated = false;
          aplic.lote = '';
          aplic.marca = '';
          var dt = vacinas![i].aplic!.last.dataaplicacao!.year + 1;
          var day = vacinas![i].aplic!.last.dataaplicacao!.day.toString();
          if (day.length <= 1) day = '0' + day;
          var month = vacinas![i].aplic!.last.dataaplicacao!.month.toString();
          if (month.length <= 1) month = '0' + month;

          var dt1 = DateTime.parse(dt.toString() +
              '-' +
              month +
              '-' +
              day +
              ' 09:00:00'); //vacinas![i].aplic![x].dtaplicnews!.add(Duration(days: 365));
          aplic.dataaplicacao = dt1;
          int id = Random().nextInt(50000);

          Localnotification.showNotificationscheduled(
            som: som,
            somios: somios,
            id: id,
            title: 'Lembrete de Vacinação',
            body: 'Olá, não esqueça da aplicação da vacina ' +
                vacinas![i].name.toString() +
                'do(a) ' +
                name.toString() +
                ' dia: ' +
                day +
                '/' +
                month +
                '/' +
                dt.toString(),
            dateTime: DateTime.parse(
                dt.toString() + '-' + month + '-' + day + ' 09:00:00'),
          );
          aplic.scheduleid = id;
          vacinas![i].aplic!.add(aplic);
        }
        if (vacinas![i].aplic![x].dtaplicnews != null &&
            vacinas![i].aplic![x].aplicated == false) {
          var dt = vacinas![i].aplic![x].dtaplicnews!.year + 1;
          var day = vacinas![i].aplic![x].dtaplicnews!.day.toString();
          if (day.length <= 1) day = '0' + day;
          var month = vacinas![i].aplic![x].dtaplicnews!.month.toString();
          if (month.length <= 1) month = '0' + month;
          var dttemp = dt.toString() +
              '-' +
              month.toString() +
              '-' +
              day.toString() +
              ' 09:00:00';
          var dt1 = DateTime.parse(
              dttemp); //vacinas![i].aplic![x].dtaplicnews!.add(Duration(days: 365));
          for (var y = x + 1; y <= vacinas![i].aplic!.length - 1; y++) {
            Localnotification.cancelnotification(
                vacinas![i].aplic![y].scheduleid as int);
            int id = Random().nextInt(50000);
            Localnotification.showNotificationscheduled(
              som: som,
              somios: somios,
              id: id,
              title: 'Lembrete de Vacinação',
              body: 'Olá, não esqueça da aplicação da vacina ' +
                  vacinas![i].name.toString() +
                  'do(a) ' +
                  name.toString() +
                  ' dia: ' +
                  day +
                  '/' +
                  month +
                  '/' +
                  dt.toString(),
              dateTime: DateTime.parse(
                  dt.toString() + '-' + month + '-' + day + ' 09:00:00'),
            );
            vacinas![i].aplic![y].scheduleid = id;
            vacinas![i].aplic![y].dataaplicacao = dt1;
            vacinas![i].aplic![y].dtaplicnews = dt1;
          }
        }
      }
    }
    if (prontuarios != null)
      for (var p = 0; p < prontuarios!.length - 1; p++) {
        if (prontuarios![p].dataretorno != null) {
          var dt = prontuarios![p].dataretorno!.year;
          var dayd = prontuarios![p].dataretorno!.day.toString();
          var day = (prontuarios![p].dataretorno!.day - 1).toString();
          if (day.length <= 1) day = '0' + day;
          var month = prontuarios![p].dataretorno!.month.toString();
          if (month.length <= 1) month = '0' + month;
          if (prontuarios![p].scheduledID == null) {
            int id = Random().nextInt(50000);
            Localnotification.showNotificationscheduled(
              som: som,
              somios: somios,
              id: id,
              title: 'Lembrete de Vacinação',
              body: 'Olá, não esqueça do retorno do procedimento: ' +
                  prontuarios![p].descricao.toString() +
                  'do(a) ' +
                  name.toString() +
                  ' dia: ' +
                  dayd +
                  '/' +
                  month +
                  '/' +
                  dt.toString(),
              dateTime: DateTime.parse(
                  dt.toString() + '-' + month + '-' + day + ' 07:00:00'),
            );

            Localnotification.showNotificationscheduled(
              id: Random().nextInt(50000),
              som: som,
              somios: somios,
              title: 'Lembrete de Vacinação',
              body: 'Olá, não esqueça do retorno do procedimento: ' +
                  prontuarios![p].descricao.toString() +
                  'do(a) ' +
                  name.toString() +
                  ' dia: ' +
                  day +
                  '/' +
                  month +
                  '/' +
                  dt.toString(),
              dateTime: DateTime.parse(
                  dt.toString() + '-' + month + '-' + day + ' 09:00:00'),
            );
            prontuarios![p].scheduledID = id.toString();
          } else {
            Localnotification.showNotificationscheduled(
              id: prontuarios![p].scheduledID,
              som: som,
              somios: somios,
              title: 'Lembrete de Vacinação',
              body: 'Olá, não esqueça do retorno do procedimento: ' +
                  prontuarios![p].descricao.toString() +
                  'do(a) ' +
                  name.toString() +
                  ' dia: ' +
                  dayd +
                  '/' +
                  month +
                  '/' +
                  dt.toString(),
              dateTime: DateTime.parse(
                  dt.toString() + '-' + month + '-' + day + ' 09:00:00'),
            );
            Localnotification.showNotificationscheduled(
              id: Random().nextInt(50000),
              som: som,
              somios: somios,
              title: 'Lembrete de Vacinação',
              body: 'Olá, não esqueça do retorno do procedimento: ' +
                  prontuarios![p].descricao.toString() +
                  'do(a) ' +
                  name.toString() +
                  ' dia: ' +
                  day +
                  '/' +
                  month +
                  '/' +
                  dt.toString(),
              dateTime: DateTime.parse(
                  dt.toString() + '-' + month + '-' + day + ' 09:00:00'),
            );
          }
        }
      }
    final Map<String, dynamic> data = {
      'name': name,
      'user_id': user_id,
      'birth': birth,
      'category_id': category_id,
      'genero_id': genero_id,
      'breed': breed,
      'color': color,
      'size': size,
      'pedigree': pedigree,
      'castrado': castrado,
      'deleted': deleted,
      'datainivacinas': datainivacinas,
      if (vacinas != null) 'vacinas': exportVacinasList(),
      if (prontuarios != null) 'prontuarios': exportProntuariosList(),
      if (pesos != null) 'pesos': exportPesosList()
    };

    if (id == null) {
      final doc = await firestore.collection('pet').add(data);
      id = doc.id;
    } else {
      await firestoreRef.update(data);
    }

    final List<String> updateImages = [];

    if (newImages != null) {
      for (final newImage in newImages!) {
        if (images!.contains(newImage)) {
          updateImages.add(newImage as String);
        } else {
          try {
            final UploadTask task =
                storageRef.child(Uuid().v1()).putFile(newImage as File);
            final TaskSnapshot snapshot = await task;
            final String url = await snapshot.ref.getDownloadURL();
            updateImages.add(url);
          } catch (e) {
            print(e);
          }
        }
      }
      for (final image in images!) {
        if (!newImages!.contains(image) && image.contains('firebase')) {
          try {
            final ref = await storage.refFromURL(image);
            await ref.delete();
          } catch (e) {
            debugPrint('Falha ao deletar $image');
          }
        }
      }
      await firestoreRef.update({'images': updateImages});
      images = updateImages;
    }

    loading = false;
    notifyListeners();
  }

  void delete() {
    firestoreRef.update({'deleted': true});
  }

  void setVacinas(Pet pet) {
    //print(pet.toString());
    save();
  }

  void setProntuarios(Pet pet) {
    //print(pet.toString());
    save();
  }

  void setPesos(Pet pet) {
    //print(pet.toString());
    save();
  }

  Pet clone() {
    if (images != null || images!.length > 0) {
      return Pet(
          id: id,
          userapp: userapp,
          name: name,
          user_id: user_id,
          birth: birth,
          category_id: category_id,
          breed: breed,
          color: color,
          size: size,
          pedigree: pedigree,
          castrado: castrado,
          genero_id: genero_id,
          images: List.from(images!),
          datainivacinas: datainivacinas,
          deleted: deleted,
          vacinas: vacinas,
          prontuarios: prontuarios,
          pesos: pesos);
    } else {
      return Pet(
          id: id,
          userapp: userapp,
          name: name,
          user_id: user_id,
          birth: birth,
          category_id: category_id,
          breed: breed,
          color: color,
          size: size,
          pedigree: pedigree,
          castrado: castrado,
          genero_id: genero_id,
          images: null,
          datainivacinas: datainivacinas,
          deleted: deleted,
          vacinas: vacinas,
          prontuarios: prontuarios,
          pesos: pesos);
    }
  }

  @override
  String toString() {
    return 'Pet{id: $id, user_id: $user_id ,name: $name, birth: $birth, category_id: $category_id, breed: $breed, color: $color, size: $size, pedigree: $pedigree, castrado: $castrado, genero_id: $genero_id, images: $images, vacinas: $vacinas, prontuarios: $prontuarios, pesos:$pesos,datainivacinas:$datainivacinas }';
  }
}
