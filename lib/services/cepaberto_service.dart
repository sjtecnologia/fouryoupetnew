import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fouryoupet/models/address/cepaberto_address.dart';

const token = 'af993c96dea311cf096dae3ed5caae07';

class CepAbertoService {
  Future<CepAbertoAddress> getAddressFromCep(String cep) async {
    final cleanCep = cep.replaceAll('.', '').replaceAll('-', '');
    final endpint = "https://www.cepaberto.com/api/v3/cep?cep=$cleanCep";

    final Dio dio = Dio();

    dio.options.headers[HttpHeaders.authorizationHeader] = 'Token token=$token';

    try {
      final response = await dio.get<Map<String, dynamic>>(endpint);

      if (response.data!.isEmpty) {
        return Future.error('CEP Inválido');
      }

      final CepAbertoAddress address = CepAbertoAddress.fromMap(response.data!);

      return address;
      // ignore: unused_catch_clause, deprecated_member_use
    } on DioError catch (e) {
      return Future.error('Erro ao buscar CEP');
    }
  }
}
