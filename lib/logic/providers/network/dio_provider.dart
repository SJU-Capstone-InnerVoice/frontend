import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DioProvider with ChangeNotifier {
  final Dio dio = Dio()
    ..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
}