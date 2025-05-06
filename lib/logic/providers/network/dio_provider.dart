import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DioProvider with ChangeNotifier {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ))..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
}