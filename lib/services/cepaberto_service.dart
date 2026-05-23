import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fouryoupet/config/api_constants.dart';
import 'package:fouryoupet/models/address/cepaberto_address.dart';

class CepAbertoService {
  Future<CepAbertoAddress> getAddressFromCep(String cep) async {
    final cleanCep = cep.replaceAll('.', '').replaceAll('-', '');
    final endpoint = "https://www.cepaberto.com/api/v3/cep?cep=$cleanCep";

    final Dio dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.headers[HttpHeaders.authorizationHeader] =
        'Token token=$CEPABERTO_TOKEN';

    try {
      final response = await dio.get<Map<String, dynamic>>(endpoint);

      if (response.data == null || response.data!.isEmpty) {
        return Future.error(
            'CEP não encontrado. Verifique o número informado.');
      }

      return CepAbertoAddress.fromMap(response.data!);
    } on DioException catch (e) {
      debugPrint('CepAbertoService error: $e');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Future.error(
            'Tempo limite excedido. Verifique sua conexão e tente novamente.');
      }
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        return Future.error(
            'CEP inválido. Confira o número e tente novamente.');
      }
      if (e.type == DioExceptionType.connectionError) {
        return Future.error('Sem conexão com a internet. Verifique sua rede.');
      }
      return Future.error('Erro ao buscar CEP. Tente novamente mais tarde.');
    }
  }
}
