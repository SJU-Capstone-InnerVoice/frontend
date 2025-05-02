import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DioProvider with ChangeNotifier {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ))..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
}